<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Transbank\Webpay\WebpayPlus\Transaction;
use Transbank\Webpay\Options;
use Illuminate\Support\Facades\Log;

class WebPayController extends Controller
{
    /**
     * Obtener la configuración de WebPay según el ambiente
     */
    private function getWebpayOptions()
    {
        $environment = config('transbank.environment');
        
        if ($environment === 'integration') {
            // Usar credenciales de integración (pruebas)
            $commerceCode = config('transbank.integration.commerce_code');
            $apiKey = config('transbank.integration.api_key');
            $integrationType = Options::ENVIRONMENT_INTEGRATION;
        } else {
            // Usar credenciales de producción
            $commerceCode = config('transbank.production.commerce_code');
            $apiKey = config('transbank.production.api_key');
            $integrationType = Options::ENVIRONMENT_PRODUCTION;
        }
        
        return new Options($apiKey, $commerceCode, $integrationType);
    }

    /**
     * Mostrar el formulario para comprar un bono
     */
    public function showForm()
    {
        $tiposBonos = \App\Models\Bono::tipos();
        
        // Obtener usuarios con rol paciente desde Firestore
        $usuarioModel = new \App\Models\Usuario();
        $todosUsuarios = $usuarioModel->all();
        
        // Filtrar solo pacientes
        $pacientes = array_filter($todosUsuarios, function($usuario) {
            return isset($usuario['rol']) && $usuario['rol'] === 'paciente';
        });
        
        // Formatear pacientes para el select con búsqueda por nombre y RUT
        $pacientesFormateados = array_map(function($paciente) {
            $nombre = $paciente['displayName'] ?? $paciente['email'] ?? 'Sin nombre';
            $rut = $paciente['rut'] ?? 'Sin RUT';
            
            return [
                'id' => $paciente['id'],
                'nombre' => $nombre,
                'email' => $paciente['email'] ?? '',
                'rut' => $rut,
                'telefono' => $paciente['telefono'] ?? '',
                'label' => $nombre . ' - ' . $rut,
            ];
        }, array_values($pacientes));
        
        return \Inertia\Inertia::render('ComprarBono', [
            'tiposBonos' => $tiposBonos,
            'pacientes' => $pacientesFormateados,
        ]);
    }

    /**
     * Iniciar una transacción de WebPay Plus
     */
    public function iniciarTransaccion(Request $request)
    {
        try {
            Log::info('🔵 Iniciando transacción WebPay', ['request_data' => $request->all()]);
            
            // Validar los datos del formulario
            $validated = $request->validate([
                'tipo_bono' => 'required|string',
                'nombre' => 'required|string|max:255',
                'email' => 'required|email|max:255',
                'rut' => 'required|string|max:12',
                'telefono' => 'required|string|max:15',
                'monto' => 'required|numeric|min:50|max:1000000',
            ]);
            
            Log::info('✅ Datos validados correctamente', ['validated' => $validated]);

            // Obtener información del bono
            $bono = \App\Models\Bono::obtenerPorId($validated['tipo_bono']);
            if (!$bono) {
                Log::error('❌ Tipo de bono no válido', ['tipo_bono' => $validated['tipo_bono']]);
                return back()->withErrors(['tipo_bono' => 'Tipo de bono no válido']);
            }
            
            Log::info('✅ Bono encontrado', ['bono' => $bono]);

            // Generar un número de orden único
            $buyOrder = 'BONO-' . time() . '-' . rand(1000, 9999);
            Log::info('📋 Orden generada', ['buy_order' => $buyOrder]);
            
            // Guardar los datos en la sesión para recuperarlos después
            session([
                'webpay_datos_paciente' => [
                    'tipo_bono' => $validated['tipo_bono'],
                    'nombre_bono' => $bono['nombre'],
                    'descripcion_bono' => $bono['descripcion'],
                    'duracion_dias' => $bono['duracion_dias'],
                    'nombre' => $validated['nombre'],
                    'email' => $validated['email'],
                    'rut' => $validated['rut'],
                    'telefono' => $validated['telefono'],
                    'monto' => $validated['monto'],
                    'buy_order' => $buyOrder,
                ]
            ]);
            
            Log::info('💾 Datos guardados en sesión');

            // Crear la transacción en WebPay
            $amount = (int) $validated['monto']; // El monto debe ser entero (sin decimales)
            $sessionId = session()->getId();
            $returnUrl = route('comprar-bono.confirmar');
            
            Log::info('🔧 Parámetros para WebPay', [
                'amount' => $amount,
                'session_id' => $sessionId,
                'return_url' => $returnUrl,
                'buy_order' => $buyOrder,
            ]);

            $response = (new Transaction($this->getWebpayOptions()))
                ->create($buyOrder, $sessionId, $amount, $returnUrl);
            
            Log::info('✅ Transacción creada en WebPay', [
                'token' => $response->getToken(),
                'url' => $response->getUrl(),
            ]);

            // Guardar el token en la sesión
            session(['webpay_token' => $response->getToken()]);

            // Construir URL completa de WebPay
            $webpayUrl = $response->getUrl() . '?token_ws=' . $response->getToken();
            
            Log::info('🚀 Redirigiendo a WebPay', ['url' => $webpayUrl]);

            // Si es una petición Inertia, devolver respuesta especial para redirección externa
            if ($request->header('X-Inertia')) {
                return \Inertia\Inertia::location($webpayUrl);
            }

            // Para peticiones normales, redirigir directamente
            return redirect($webpayUrl);

        } catch (\Exception $e) {
            Log::error('❌ Error al iniciar transacción WebPay', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            return back()->with('error', 'Error al iniciar la transacción: ' . $e->getMessage());
        }
    }

    /**
     * Confirmar la transacción después del pago
     */
    public function confirmarTransaccion(Request $request)
    {
        try {
            Log::info('🔵 Confirmando transacción WebPay', ['request_data' => $request->all()]);
            
            $token = $request->get('token_ws');
            
            if (!$token) {
                Log::error('❌ Token no encontrado en la petición');
                return redirect()->route('comprar-bono')->with('error', 'Token no encontrado');
            }
            
            Log::info('🔑 Token recibido', ['token' => $token]);

            // Confirmar la transacción
            Log::info('📞 Llamando a WebPay para confirmar transacción...');
            $response = (new Transaction($this->getWebpayOptions()))
                ->commit($token);
            
            Log::info('✅ Respuesta de WebPay recibida', [
                'buy_order' => $response->getBuyOrder(),
                'status' => $response->getStatus(),
                'response_code' => $response->getResponseCode(),
                'approved' => $response->isApproved(),
            ]);

            // Obtener los datos del paciente de la sesión
            $datosPaciente = session('webpay_datos_paciente', []);
            Log::info('💾 Datos del paciente desde sesión', ['datos_encontrados' => !empty($datosPaciente)]);

            // Determinar si la transacción fue exitosa
            $isApproved = $response->isApproved();
            Log::info($isApproved ? '✅ Transacción APROBADA' : '❌ Transacción RECHAZADA');

            // Preparar los datos para la vista
            $resultado = [
                'approved' => $isApproved,
                'buy_order' => $response->getBuyOrder(),
                'session_id' => $response->getSessionId(),
                'card_number' => $response->getCardNumber() ?? 'N/A',
                'accounting_date' => $response->getAccountingDate(),
                'transaction_date' => $response->getTransactionDate(),
                'authorization_code' => $response->getAuthorizationCode(),
                'payment_type_code' => $response->getPaymentTypeCode(),
                'response_code' => $response->getResponseCode(),
                'amount' => $response->getAmount(),
                'installments_number' => $response->getInstallmentsNumber(),
                'installments_amount' => $response->getInstallmentsAmount(),
                'status' => $response->getStatus(),
                'vci' => $response->getVci(),
                'balance' => $response->getBalance(),
            ];

            // Guardar el resultado en la sesión para poder descargarlo
            session(['webpay_resultado' => array_merge($resultado, $datosPaciente)]);
            Log::info('💾 Resultado guardado en sesión');

            return \Inertia\Inertia::render('ResultadoBono', [
                'resultado' => $resultado,
                'datosPaciente' => $datosPaciente,
            ]);

        } catch (\Exception $e) {
            Log::error('❌ Error al confirmar transacción WebPay', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            return redirect()->route('comprar-bono')->with('error', 'Error al confirmar la transacción: ' . $e->getMessage());
        }
    }

    /**
     * Descargar el comprobante de la transacción en formato JSON
     */
    public function descargarComprobante()
    {
        $resultado = session('webpay_resultado');

        if (!$resultado) {
            return redirect()->route('webpay.form')->with('error', 'No hay datos de transacción disponibles');
        }

        $fileName = 'comprobante-bono-' . ($resultado['buy_order'] ?? 'unknown') . '.json';

        return response()->json($resultado, 200, [
            'Content-Type' => 'application/json',
            'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
        ]);
    }

    /**
     * Descargar el comprobante de la transacción en formato HTML/PDF
     */
    public function descargarComprobantePDF()
    {
        $resultado = session('webpay_resultado');

        if (!$resultado) {
            return redirect()->route('webpay.form')->with('error', 'No hay datos de transacción disponibles');
        }

        $html = view('webpay.comprobante', ['resultado' => $resultado])->render();

        return response($html, 200, [
            'Content-Type' => 'text/html',
            'Content-Disposition' => 'attachment; filename="comprobante-bono-' . ($resultado['buy_order'] ?? 'unknown') . '.html"',
        ]);
    }
}
