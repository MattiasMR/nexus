<?php

namespace App\Http\Controllers;

use App\Models\Paciente;
use App\Models\FichaMedica;
use App\Models\Consulta;
use App\Models\Hospitalizacion;
use App\Models\OrdenExamen;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    /**
     * Muestra el dashboard principal del sistema médico
     */
    public function index(): Response
    {
        try {
            // Instanciar modelos
            $pacienteModel = new Paciente();
            $fichaMedicaModel = new FichaMedica();
            $consultaModel = new Consulta();
            $hospitalizacionModel = new Hospitalizacion();
            $ordenExamenModel = new OrdenExamen();

            // Obtener datos
            $pacientes = $pacienteModel->all();
            $fichasMedicas = $fichaMedicaModel->all();
            $consultas = $consultaModel->all();

            // KPI 1: Total de pacientes activos
            $totalPacientes = count($pacientes);

            // KPI 2: Total de fichas médicas creadas
            $totalFichas = count($fichasMedicas);

            // KPI 3: Fichas creadas este mes
            $fichasEsteMes = 0;
            foreach ($fichasMedicas as $ficha) {
                if (isset($ficha['fechaCreacion'])) {
                    $fechaCreacion = Carbon::parse($ficha['fechaCreacion']);
                    if ($fechaCreacion->isCurrentMonth()) {
                        $fichasEsteMes++;
                    }
                }
            }

            // KPI 4: Atenciones del día (consultas hoy)
            $atencionesHoy = 0;
            foreach ($consultas as $consulta) {
                if (isset($consulta['fecha'])) {
                    $fechaConsulta = Carbon::parse($consulta['fecha']);
                    if ($fechaConsulta->isToday()) {
                        $atencionesHoy++;
                    }
                }
            }

            // KPI 5: Atenciones del mes
            $atencionesMes = 0;
            foreach ($consultas as $consulta) {
                if (isset($consulta['fecha'])) {
                    $fechaConsulta = Carbon::parse($consulta['fecha']);
                    if ($fechaConsulta->isCurrentMonth()) {
                        $atencionesMes++;
                    }
                }
            }

            // KPI 6: Hospitalizaciones activas
            $hospitalizacionesActivas = 0;
            try {
                $hospitalizaciones = $hospitalizacionModel->findActivas();
                $hospitalizacionesActivas = count($hospitalizaciones);
            } catch (\Exception $e) {
                // Si no hay hospitalizaciones, se mantiene en 0
            }

            // KPI 7: Exámenes pendientes
            $examenesPendientes = 0;
            try {
                $ordenesPendientes = $ordenExamenModel->findByEstado('pendiente');
                $examenesPendientes = count($ordenesPendientes);
            } catch (\Exception $e) {
                // Si no hay órdenes, se mantiene en 0
            }

            // KPI 8: Alertas críticas
            logger()->info('🔍 [Dashboard] Procesando alertas críticas...');
            $alertasCriticas = 0;
            $pacientesConAlertas = [];
            $usuarioModel = new \App\Models\Usuario();
            
            foreach ($pacientes as $paciente) {
                if (isset($paciente['alertasMedicas']) && is_array($paciente['alertasMedicas'])) {
                    logger()->info('📋 [Dashboard] Procesando alertas de paciente', [
                        'idPaciente' => $paciente['id'] ?? 'sin-id',
                        'nombre' => $paciente['nombre'] ?? null,
                        'apellido' => $paciente['apellido'] ?? null,
                        'idUsuario' => $paciente['idUsuario'] ?? null,
                        'cantidadAlertas' => count($paciente['alertasMedicas'])
                    ]);
                    
                    // Obtener datos del usuario vinculado
                    $usuario = null;
                    if (isset($paciente['idUsuario'])) {
                        try {
                            $usuario = $usuarioModel->find($paciente['idUsuario']);
                            logger()->info('👤 [Dashboard] Usuario encontrado', [
                                'idUsuario' => $paciente['idUsuario'],
                                'displayName' => $usuario['displayName'] ?? null,
                                'rut' => $usuario['rut'] ?? null
                            ]);
                        } catch (\Exception $e) {
                            logger()->warning('⚠️ [Dashboard] Usuario no encontrado', [
                                'idUsuario' => $paciente['idUsuario'],
                                'error' => $e->getMessage()
                            ]);
                        }
                    } else {
                        logger()->warning('⚠️ [Dashboard] Paciente sin idUsuario vinculado', [
                            'idPaciente' => $paciente['id'] ?? 'sin-id'
                        ]);
                    }
                    
                    // Construir nombre completo del paciente
                    $nombrePaciente = 'Paciente desconocido';
                    $nombreDesdePaciente = '';
                    
                    if (isset($paciente['nombre']) || isset($paciente['apellido'])) {
                        $nombreDesdePaciente = trim(($paciente['nombre'] ?? '') . ' ' . ($paciente['apellido'] ?? ''));
                    }
                    
                    // Si tiene nombre válido desde paciente, usarlo
                    if (!empty($nombreDesdePaciente)) {
                        $nombrePaciente = $nombreDesdePaciente;
                        logger()->info('✅ [Dashboard] Nombre desde datos del paciente', ['nombre' => $nombrePaciente]);
                    }
                    // Si no, buscar en usuario
                    elseif ($usuario && isset($usuario['displayName'])) {
                        $nombrePaciente = $usuario['displayName'];
                        logger()->info('✅ [Dashboard] Nombre desde usuario vinculado', ['nombre' => $nombrePaciente]);
                    }
                    else {
                        logger()->warning('❌ [Dashboard] No se pudo determinar nombre del paciente', [
                            'idPaciente' => $paciente['id'] ?? 'sin-id',
                            'tienePacienteNombre' => isset($paciente['nombre']),
                            'tienePacienteApellido' => isset($paciente['apellido']),
                            'tieneUsuario' => !is_null($usuario),
                            'tieneUsuarioDisplayName' => $usuario ? isset($usuario['displayName']) : false,
                            'usuarioKeys' => $usuario ? array_keys($usuario) : []
                        ]);
                    }
                    
                    // Obtener RUT
                    $rut = 'N/A';
                    if ($usuario && isset($usuario['rut'])) {
                        $rut = $usuario['rut'];
                    }
                    
                    foreach ($paciente['alertasMedicas'] as $alerta) {
                        if (in_array($alerta['severidad'] ?? '', ['critica', 'alta'])) {
                            $alertasCriticas++;
                            $pacientesConAlertas[] = [
                                'paciente' => $nombrePaciente,
                                'rut' => $rut,
                                'descripcion' => $alerta['descripcion'] ?? 'Sin descripción',
                                'severidad' => $alerta['severidad'] ?? 'media',
                                'fecha' => isset($alerta['fecha']) ? Carbon::parse($alerta['fecha'])->format('d/m/Y') : 'N/A',
                            ];
                            logger()->info('🚨 [Dashboard] Alerta agregada', [
                                'paciente' => $nombrePaciente,
                                'severidad' => $alerta['severidad'] ?? 'media'
                            ]);
                        }
                    }
                }
            }
            
            logger()->info('✅ [Dashboard] Alertas procesadas', [
                'total' => $alertasCriticas,
                'mostradas' => count($pacientesConAlertas)
            ]);

            // Estadísticas para el dashboard
            $stats = [
                [
                    'value' => number_format($totalPacientes, 0, ',', '.'),
                    'title' => 'Pacientes Activos',
                    'subtitle' => 'Total en el sistema',
                    'icon' => 'users',
                    'color' => 'blue',
                    'trend' => null,
                ],
                [
                    'value' => number_format($totalFichas, 0, ',', '.'),
                    'title' => 'Fichas Médicas',
                    'subtitle' => '+' . $fichasEsteMes . ' este mes',
                    'icon' => 'file-text',
                    'color' => 'green',
                    'trend' => $fichasEsteMes > 0 ? 'up' : 'stable',
                ],
                [
                    'value' => number_format($atencionesHoy, 0, ',', '.'),
                    'title' => 'Atenciones Hoy',
                    'subtitle' => number_format($atencionesMes, 0, ',', '.') . ' este mes',
                    'icon' => 'calendar-check',
                    'color' => 'purple',
                    'trend' => $atencionesHoy > 0 ? 'up' : 'stable',
                ],
                [
                    'value' => number_format($hospitalizacionesActivas, 0, ',', '.'),
                    'title' => 'Hospitalizaciones',
                    'subtitle' => 'Pacientes internados',
                    'icon' => 'bed',
                    'color' => 'orange',
                    'trend' => null,
                ],
                [
                    'value' => number_format($examenesPendientes, 0, ',', '.'),
                    'title' => 'Exámenes Pendientes',
                    'subtitle' => 'Por revisar',
                    'icon' => 'flask-conical',
                    'color' => 'yellow',
                    'trend' => $examenesPendientes > 0 ? 'attention' : 'stable',
                ],
                [
                    'value' => number_format($alertasCriticas, 0, ',', '.'),
                    'title' => 'Alertas Críticas',
                    'subtitle' => 'Requieren atención',
                    'icon' => 'alert-triangle',
                    'color' => 'red',
                    'trend' => $alertasCriticas > 0 ? 'attention' : 'stable',
                ],
            ];

            // Actividad reciente (últimas 10 consultas)
            logger()->info('📅 [Dashboard] Procesando actividad reciente...');
            $actividadReciente = [];
            $consultasOrdenadas = $consultas;
            usort($consultasOrdenadas, function($a, $b) {
                $fechaA = isset($a['fecha']) ? Carbon::parse($a['fecha']) : Carbon::now();
                $fechaB = isset($b['fecha']) ? Carbon::parse($b['fecha']) : Carbon::now();
                return $fechaB->timestamp - $fechaA->timestamp;
            });

            logger()->info('📊 [Dashboard] Consultas ordenadas', [
                'total' => count($consultasOrdenadas),
                'mostrar' => min(10, count($consultasOrdenadas))
            ]);

            $usuarioModel = new \App\Models\Usuario();
            
            foreach (array_slice($consultasOrdenadas, 0, 10) as $consulta) {
                logger()->info('🔍 [Dashboard] Procesando consulta', [
                    'idConsulta' => $consulta['id'] ?? 'sin-id',
                    'pacienteId' => $consulta['pacienteId'] ?? null,
                    'idPaciente' => $consulta['idPaciente'] ?? null
                ]);
                
                // Buscar el paciente y su usuario vinculado
                $paciente = null;
                $usuario = null;
                $nombrePaciente = 'Paciente desconocido';
                
                // Intentar con ambos campos posibles
                $pacienteId = $consulta['pacienteId'] ?? $consulta['idPaciente'] ?? null;
                
                if ($pacienteId) {
                    try {
                        $paciente = $pacienteModel->find($pacienteId);
                        logger()->info('📋 [Dashboard] Paciente encontrado', [
                            'idPaciente' => $pacienteId,
                            'nombre' => $paciente['nombre'] ?? null,
                            'apellido' => $paciente['apellido'] ?? null,
                            'idUsuario' => $paciente['idUsuario'] ?? null
                        ]);
                        
                        if ($paciente) {
                            // Intentar construir nombre desde datos del paciente
                            $nombreDesdePariente = '';
                            if (isset($paciente['nombre']) || isset($paciente['apellido'])) {
                                $nombreDesdePariente = trim(($paciente['nombre'] ?? '') . ' ' . ($paciente['apellido'] ?? ''));
                            }
                            
                            // Si tiene nombre válido desde paciente, usarlo
                            if (!empty($nombreDesdePariente)) {
                                $nombrePaciente = $nombreDesdePariente;
                                logger()->info('✅ [Dashboard] Nombre desde paciente', ['nombre' => $nombrePaciente]);
                            }
                            // Si no, buscar en usuario
                            elseif (isset($paciente['idUsuario'])) {
                                try {
                                    $usuario = $usuarioModel->find($paciente['idUsuario']);
                                    if ($usuario && isset($usuario['displayName'])) {
                                        $nombrePaciente = $usuario['displayName'];
                                        logger()->info('✅ [Dashboard] Nombre desde usuario', ['nombre' => $nombrePaciente]);
                                    } else {
                                        logger()->warning('⚠️ [Dashboard] Usuario sin displayName', [
                                            'idUsuario' => $paciente['idUsuario'],
                                            'usuarioKeys' => $usuario ? array_keys($usuario) : []
                                        ]);
                                    }
                                } catch (\Exception $e) {
                                    logger()->warning('⚠️ [Dashboard] Error buscando usuario', [
                                        'idUsuario' => $paciente['idUsuario'],
                                        'error' => $e->getMessage()
                                    ]);
                                }
                            }
                            
                            if ($nombrePaciente === 'Paciente desconocido') {
                                logger()->warning('❌ [Dashboard] No se pudo determinar nombre', [
                                    'idPaciente' => $pacienteId,
                                    'tienePacienteNombre' => isset($paciente['nombre']),
                                    'tienePacienteApellido' => isset($paciente['apellido']),
                                    'tieneIdUsuario' => isset($paciente['idUsuario'])
                                ]);
                            }
                        }
                    } catch (\Exception $e) {
                        logger()->error('❌ [Dashboard] Error buscando paciente', [
                            'pacienteId' => $pacienteId,
                            'error' => $e->getMessage()
                        ]);
                        // Paciente no encontrado
                    }
                } else {
                    logger()->warning('⚠️ [Dashboard] Consulta sin pacienteId/idPaciente', [
                        'idConsulta' => $consulta['id'] ?? 'sin-id',
                        'keys' => array_keys($consulta)
                    ]);
                }

                $actividadReciente[] = [
                    'id' => $consulta['id'] ?? uniqid(),
                    'paciente' => $nombrePaciente,
                    'tipo' => 'Consulta Médica',
                    'motivo' => $consulta['motivoConsulta'] ?? 'Sin motivo especificado',
                    'fecha' => isset($consulta['fecha']) ? Carbon::parse($consulta['fecha'])->format('d/m/Y H:i') : 'N/A',
                    'fechaRelativa' => isset($consulta['fecha']) ? Carbon::parse($consulta['fecha'])->diffForHumans() : 'N/A',
                ];
            }
            
            logger()->info('✅ [Dashboard] Actividad reciente procesada', [
                'total' => count($actividadReciente)
            ]);

            return Inertia::render('Dashboard', [
                'stats' => $stats,
                'alertas' => array_slice($pacientesConAlertas, 0, 10),
                'actividadReciente' => $actividadReciente,
                'isLoading' => false,
                'resumen' => [
                    'totalPacientes' => $totalPacientes,
                    'totalFichas' => $totalFichas,
                    'atencionesMes' => $atencionesMes,
                    'hospitalizacionesActivas' => $hospitalizacionesActivas,
                ],
            ]);

        } catch (\Exception $e) {
            // En caso de error, mostrar dashboard con datos vacíos
            return $this->fallbackDashboard($e->getMessage());
        }
    }


    /**
     * Dashboard de respaldo si Firebase falla
     */
    private function fallbackDashboard(string $error): Response
    {
        $stats = [
            [
                'value' => '0',
                'title' => 'Pacientes Activos',
                'subtitle' => 'Firebase no disponible',
                'icon' => 'users',
                'color' => 'blue',
                'trend' => null,
            ],
            [
                'value' => '0',
                'title' => 'Fichas Médicas',
                'subtitle' => 'Firebase no disponible',
                'icon' => 'file-text',
                'color' => 'green',
                'trend' => null,
            ],
            [
                'value' => '0',
                'title' => 'Atenciones Hoy',
                'subtitle' => 'Firebase no disponible',
                'icon' => 'calendar-check',
                'color' => 'purple',
                'trend' => null,
            ],
            [
                'value' => '0',
                'title' => 'Hospitalizaciones',
                'subtitle' => 'Firebase no disponible',
                'icon' => 'bed',
                'color' => 'orange',
                'trend' => null,
            ],
            [
                'value' => '0',
                'title' => 'Exámenes Pendientes',
                'subtitle' => 'Firebase no disponible',
                'icon' => 'flask-conical',
                'color' => 'yellow',
                'trend' => null,
            ],
            [
                'value' => '0',
                'title' => 'Alertas Críticas',
                'subtitle' => 'Firebase no disponible',
                'icon' => 'alert-triangle',
                'color' => 'red',
                'trend' => null,
            ],
        ];

        return Inertia::render('Dashboard', [
            'stats' => $stats,
            'alertas' => [],
            'actividadReciente' => [],
            'isLoading' => false,
            'error' => 'Error de conexión con Firebase: ' . $error,
        ]);
    }
}
