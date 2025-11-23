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
        
        // Obtener todos los pacientes desde Firestore
        $pacienteModel = new \App\Models\Paciente();
        $pacientes = $pacienteModel->all();
        
        // Formatear pacientes para el select
        $pacientesFormateados = array_map(function($paciente) {
            return [
                'id' => $paciente['id'],
                'nombre' => $paciente['nombre'] ?? '',
                'email' => $paciente['email'] ?? '',
                'rut' => $paciente['rut'] ?? '',
                'telefono' => $paciente['telefono'] ?? '',
                'label' => ($paciente['nombre'] ?? 'Sin nombre') . ' - ' . ($paciente['rut'] ?? 'Sin RUT'),
            ];
        }, $pacientes);
        
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
            // Validar los datos del formulario
            $validated = $request->validate([
                'tipo_bono' => 'required|string',
                'nombre' => 'required|string|max:255',
                'email' => 'required|email|max:255',
                'rut' => 'required|string|max:12',
                'telefono' => 'required|string|max:15',
                'monto' => 'required|numeric|min:50|max:1000000',
            ]);

            // Obtener información del bono
            $bono = \App\Models\Bono::obtenerPorId($validated['tipo_bono']);
            if (!$bono) {
                return back()->withErrors(['tipo_bono' => 'Tipo de bono no válido']);
            }

            // Generar un número de orden único
            $buyOrder = 'BONO-' . time() . '-' . rand(1000, 9999);
            
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

            // Crear la transacción en WebPay
            $amount = (int) $validated['monto']; // El monto debe ser entero (sin decimales)
            $sessionId = session()->getId();
            $returnUrl = route('webpay.confirmar');

            $response = (new Transaction($this->getWebpayOptions()))
                ->create($buyOrder, $sessionId, $amount, $returnUrl);

            // Guardar el token en la sesión
            session(['webpay_token' => $response->getToken()]);

            // Construir URL completa de WebPay
            $webpayUrl = $response->getUrl() . '?token_ws=' . $response->getToken();

            // Si es una petición Inertia, devolver respuesta especial para redirección externa
            if ($request->header('X-Inertia')) {
                return \Inertia\Inertia::location($webpayUrl);
            }

            // Para peticiones normales, redirigir directamente
            return redirect($webpayUrl);

        } catch (\Exception $e) {
            Log::error('Error al iniciar transacción WebPay: ' . $e->getMessage());
            return back()->with('error', 'Error al iniciar la transacción: ' . $e->getMessage());
        }
    }

    /**
     * Confirmar la transacción después del pago
     */
    public function confirmarTransaccion(Request $request)
    {
        try {
            $token = $request->get('token_ws');
            
            if (!$token) {
                return redirect()->route('webpay.form')->with('error', 'Token no encontrado');
            }

            // Confirmar la transacción
            $response = (new Transaction($this->getWebpayOptions()))
                ->commit($token);

            // Obtener los datos del paciente de la sesión
            $datosPaciente = session('webpay_datos_paciente', []);

            // Determinar si la transacción fue exitosa
            $isApproved = $response->isApproved();

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

            return \Inertia\Inertia::render('ResultadoBono', [
                'resultado' => $resultado,
                'datosPaciente' => $datosPaciente,
            ]);

        } catch (\Exception $e) {
            Log::error('Error al confirmar transacción WebPay: ' . $e->getMessage());
            return redirect()->route('webpay.form')->with('error', 'Error al confirmar la transacción: ' . $e->getMessage());
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
