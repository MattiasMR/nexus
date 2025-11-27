<?php

namespace App\Http\Controllers;

use App\Models\FichaMedica;
use App\Models\Paciente;
use App\Models\Usuario;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Barryvdh\DomPDF\Facade\Pdf as PDF;

class FichaMedicaController extends Controller
{
    /**
     * Mostrar listado de pacientes con fichas médicas
     */
    public function index(Request $request)
    {
        try {
            logger()->info('🔵 Cargando listado de gestión médica');

            $usuarioModel = new Usuario();
            $pacienteModel = new Paciente();
            $fichaModel = new FichaMedica();

            // Obtener todos los usuarios con rol='paciente'
            $usuarios = $usuarioModel->all();
            $pacientes = array_filter($usuarios, function($usuario) {
                return isset($usuario['rol']) && $usuario['rol'] === 'paciente';
            });

            // Aplicar filtros
            $busqueda = $request->get('busqueda');
            $tieneAlergias = $request->get('tieneAlergias');

            // Construir datos completos de pacientes con fichas
            $pacientesCompletos = [];
            foreach ($pacientes as $usuario) {
                // Obtener datos del paciente
                $paciente = null;
                if (isset($usuario['idPaciente'])) {
                    $paciente = $pacienteModel->find($usuario['idPaciente']);
                }

                // Obtener ficha médica
                $fichaMedica = null;
                if ($paciente) {
                    $fichaMedica = $fichaModel->findByPaciente($paciente['id']);
                }

                $pacienteCompleto = [
                    // Datos del usuario
                    'id' => $usuario['id'],
                    'displayName' => $usuario['displayName'] ?? 'Sin nombre',
                    'email' => $usuario['email'] ?? 'Sin email',
                    'rut' => $usuario['rut'] ?? null,
                    'telefono' => $usuario['telefono'] ?? null,
                    'photoURL' => $usuario['photoURL'] ?? null,
                    'activo' => $usuario['activo'] ?? false,
                    
                    // Datos del paciente
                    'idPaciente' => $paciente['id'] ?? null,
                    'grupoSanguineo' => $paciente['grupoSanguineo'] ?? null,
                    'prevision' => $paciente['prevision'] ?? null,
                    
                    // Datos de la ficha médica
                    'idFicha' => $fichaMedica['id'] ?? null,
                    'tieneFicha' => $fichaMedica !== null,
                    'totalConsultas' => $fichaMedica['totalConsultas'] ?? 0,
                    'ultimaConsulta' => $fichaMedica['ultimaConsulta'] ?? null,
                    'tieneAlergias' => !empty($fichaMedica['antecedentes']['alergias'] ?? []),
                    'observacion' => $fichaMedica['observacion'] ?? null,
                ];

                // Filtrar por búsqueda
                if ($busqueda) {
                    $busquedaLower = strtolower($busqueda);
                    $nombre = strtolower($pacienteCompleto['displayName']);
                    $email = strtolower($pacienteCompleto['email']);
                    $rut = strtolower($pacienteCompleto['rut'] ?? '');
                    
                    if (!str_contains($nombre, $busquedaLower) && 
                        !str_contains($email, $busquedaLower) &&
                        !str_contains($rut, $busquedaLower)) {
                        continue;
                    }
                }

                // Filtrar por alergias
                if ($tieneAlergias === 'si' && !$pacienteCompleto['tieneAlergias']) {
                    continue;
                }
                if ($tieneAlergias === 'no' && $pacienteCompleto['tieneAlergias']) {
                    continue;
                }

                $pacientesCompletos[] = $pacienteCompleto;
            }

            // Ordenar por última consulta
            usort($pacientesCompletos, function($a, $b) {
                $dateA = $a['ultimaConsulta'] ?? null;
                $dateB = $b['ultimaConsulta'] ?? null;
                
                if (!$dateA && !$dateB) return 0;
                if (!$dateA) return 1;
                if (!$dateB) return -1;
                
                return $dateB <=> $dateA;
            });

            // Calcular estadísticas
            $stats = [
                'total' => count($pacientesCompletos),
                'conFicha' => count(array_filter($pacientesCompletos, fn($p) => $p['tieneFicha'])),
                'sinFicha' => count(array_filter($pacientesCompletos, fn($p) => !$p['tieneFicha'])),
                'conAlergias' => count(array_filter($pacientesCompletos, fn($p) => $p['tieneAlergias'])),
            ];

            logger()->info('✅ Listado cargado correctamente', [
                'total' => $stats['total'],
                'conFicha' => $stats['conFicha']
            ]);

            return Inertia::render('GestionMedica/Index', [
                'pacientes' => array_values($pacientesCompletos),
                'filtros' => [
                    'busqueda' => $busqueda ?? '',
                    'tieneAlergias' => $tieneAlergias ?? 'todos',
                ],
                'stats' => $stats,
            ]);

        } catch (\Exception $e) {
            logger()->error('❌ Error en index de gestión médica: ' . $e->getMessage());
            
            return Inertia::render('GestionMedica/Index', [
                'pacientes' => [],
                'filtros' => [
                    'busqueda' => '',
                    'tieneAlergias' => 'todos',
                ],
                'stats' => [
                    'total' => 0,
                    'conFicha' => 0,
                    'sinFicha' => 0,
                    'conAlergias' => 0,
                ],
                'error' => 'Error al cargar los pacientes: ' . $e->getMessage(),
            ]);
        }
    }

    /**
     * Mostrar ficha médica de un paciente
     */
    public function show(string $idPaciente)
    {
        try {
            logger()->info('🔵 Mostrando ficha médica del paciente', ['idPaciente' => $idPaciente]);

            $pacienteModel = new Paciente();
            $usuarioModel = new Usuario();
            $fichaModel = new FichaMedica();

            // Obtener datos del paciente
            $paciente = $pacienteModel->find($idPaciente);
            if (!$paciente) {
                return redirect()->route('gestion-medica.index')
                    ->with('error', 'Paciente no encontrado');
            }

            // Obtener datos del usuario
            $usuario = null;
            if (isset($paciente['idUsuario'])) {
                $usuario = $usuarioModel->find($paciente['idUsuario']);
            }

            if (!$usuario) {
                return redirect()->route('gestion-medica.index')
                    ->with('error', 'Usuario del paciente no encontrado');
            }

            // Obtener ficha médica
            $fichaMedica = $fichaModel->findByPaciente($idPaciente);

            // Si no tiene ficha, crear una vacía
            if (!$fichaMedica) {
                logger()->info('📝 Creando ficha médica vacía para paciente', ['idPaciente' => $idPaciente]);
                
                $fichaId = $fichaModel->create([
                    'idPaciente' => $idPaciente,
                    'antecedentes' => [
                        'alergias' => [],
                        'familiares' => '',
                        'hospitalizaciones' => '',
                        'personales' => '',
                        'quirurgicos' => '',
                    ],
                    'observacion' => '',
                    'fechaMedica' => now()->toISOString(),
                ]);

                $fichaMedica = $fichaModel->find($fichaId);
            }

            $datosCompletos = [
                // Datos del usuario
                'usuario' => [
                    'id' => $usuario['id'],
                    'displayName' => $usuario['displayName'] ?? 'Sin nombre',
                    'email' => $usuario['email'] ?? 'Sin email',
                    'rut' => $usuario['rut'] ?? null,
                    'telefono' => $usuario['telefono'] ?? null,
                    'photoURL' => $usuario['photoURL'] ?? null,
                ],
                
                // Datos del paciente
                'paciente' => [
                    'id' => $paciente['id'],
                    'grupoSanguineo' => $paciente['grupoSanguineo'] ?? null,
                    'prevision' => $paciente['prevision'] ?? null,
                    'fechaNacimiento' => $paciente['fechaNacimiento'] ?? null,
                    'contactoEmergencia' => $paciente['contactoEmergencia'] ?? null,
                ],
                
                // Ficha médica
                'ficha' => $fichaMedica,
            ];

            logger()->info('✅ Ficha médica cargada', ['idFicha' => $fichaMedica['id']]);

            return Inertia::render('GestionMedica/Show', $datosCompletos);

        } catch (\Exception $e) {
            logger()->error('❌ Error mostrando ficha médica: ' . $e->getMessage());
            
            return redirect()->route('gestion-medica.index')
                ->with('error', 'Error al cargar la ficha médica');
        }
    }

    /**
     * Actualizar ficha médica
     */
    public function update(Request $request, string $idFicha)
    {
        $validated = $request->validate([
            'antecedentes' => 'nullable|array',
            'antecedentes.alergias' => 'nullable|array',
            'antecedentes.familiares' => 'nullable|string',
            'antecedentes.hospitalizaciones' => 'nullable|string',
            'antecedentes.personales' => 'nullable|string',
            'antecedentes.quirurgicos' => 'nullable|string',
            'observacion' => 'nullable|string',
        ]);

        try {
            logger()->info('🔵 Actualizando ficha médica', ['idFicha' => $idFicha]);

            $fichaModel = new FichaMedica();
            $ficha = $fichaModel->find($idFicha);

            if (!$ficha) {
                return back()->with('error', 'Ficha médica no encontrada');
            }

            // Actualizar ficha médica
            $fichaModel->update($idFicha, [
                'antecedentes' => $validated['antecedentes'] ?? [],
                'observacion' => $validated['observacion'] ?? '',
            ]);

            logger()->info('✅ Ficha médica actualizada exitosamente', ['idFicha' => $idFicha]);

            return back()->with('success', 'Ficha médica actualizada correctamente');

        } catch (\Exception $e) {
            logger()->error('❌ Error actualizando ficha médica: ' . $e->getMessage());
            
            return back()->with('error', 'Error al actualizar la ficha médica: ' . $e->getMessage());
        }
    }

    /**
     * Eliminar ficha médica
     */
    public function destroy(string $idFicha)
    {
        try {
            logger()->info('🔵 Eliminando ficha médica', ['idFicha' => $idFicha]);

            $fichaModel = new FichaMedica();
            $ficha = $fichaModel->find($idFicha);

            if (!$ficha) {
                return back()->with('error', 'Ficha médica no encontrada');
            }

            // Eliminar ficha (se puede agregar validación adicional si es necesario)
            $this->firestore = app(\Kreait\Firebase\Contract\Firestore::class);
            $this->firestore->database()
                ->collection('fichasMedicas')
                ->document($idFicha)
                ->delete();

            logger()->info('✅ Ficha médica eliminada', ['idFicha' => $idFicha]);

            return redirect()->route('gestion-medica.index')
                ->with('success', 'Ficha médica eliminada correctamente');

        } catch (\Exception $e) {
            logger()->error('❌ Error eliminando ficha médica: ' . $e->getMessage());
            
            return back()->with('error', 'Error al eliminar la ficha médica');
        }
    }

    /**
     * Exportar ficha médica a PDF
     */
    public function exportPdf(string $idPaciente)
    {
        try {
            logger()->info('🔵 Exportando ficha médica a PDF', ['idPaciente' => $idPaciente]);

            $pacienteModel = new Paciente();
            $usuarioModel = new Usuario();
            $fichaModel = new FichaMedica();

            // Obtener datos completos
            $paciente = $pacienteModel->find($idPaciente);
            $usuario = $usuarioModel->find($paciente['idUsuario']);
            $fichaMedica = $fichaModel->findByPaciente($idPaciente);

            if (!$fichaMedica) {
                return back()->with('error', 'El paciente no tiene ficha médica');
            }

            $data = [
                'usuario' => $usuario,
                'paciente' => $paciente,
                'ficha' => $fichaMedica,
                'fecha' => now()->format('d/m/Y'),
            ];

            $pdf = PDF::loadView('pdf.ficha-medica', $data);
            
            $nombreArchivo = 'ficha_medica_' . ($usuario['rut'] ?? 'sin_rut') . '_' . now()->format('Y-m-d') . '.pdf';

            logger()->info('✅ PDF generado correctamente');

            return $pdf->download($nombreArchivo);

        } catch (\Exception $e) {
            logger()->error('❌ Error generando PDF: ' . $e->getMessage());
            
            return back()->with('error', 'Error al generar el PDF');
        }
    }
}
