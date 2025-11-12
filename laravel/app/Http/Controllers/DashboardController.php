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
            $alertasCriticas = 0;
            $pacientesConAlertas = [];
            foreach ($pacientes as $paciente) {
                if (isset($paciente['alertasMedicas']) && is_array($paciente['alertasMedicas'])) {
                    foreach ($paciente['alertasMedicas'] as $alerta) {
                        if (in_array($alerta['severidad'] ?? '', ['critica', 'alta'])) {
                            $alertasCriticas++;
                            $pacientesConAlertas[] = [
                                'paciente' => $paciente['nombre'] . ' ' . $paciente['apellido'],
                                'rut' => $paciente['rut'] ?? 'N/A',
                                'descripcion' => $alerta['descripcion'] ?? 'Sin descripción',
                                'severidad' => $alerta['severidad'] ?? 'media',
                                'fecha' => isset($alerta['fecha']) ? Carbon::parse($alerta['fecha'])->format('d/m/Y') : 'N/A',
                            ];
                        }
                    }
                }
            }

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
            $actividadReciente = [];
            $consultasOrdenadas = $consultas;
            usort($consultasOrdenadas, function($a, $b) {
                $fechaA = isset($a['fecha']) ? Carbon::parse($a['fecha']) : Carbon::now();
                $fechaB = isset($b['fecha']) ? Carbon::parse($b['fecha']) : Carbon::now();
                return $fechaB->timestamp - $fechaA->timestamp;
            });

            foreach (array_slice($consultasOrdenadas, 0, 10) as $consulta) {
                // Buscar el paciente
                $paciente = null;
                if (isset($consulta['pacienteId'])) {
                    try {
                        $paciente = $pacienteModel->find($consulta['pacienteId']);
                    } catch (\Exception $e) {
                        // Paciente no encontrado
                    }
                }

                $actividadReciente[] = [
                    'id' => $consulta['id'] ?? uniqid(),
                    'paciente' => $paciente ? ($paciente['nombre'] . ' ' . $paciente['apellido']) : 'Paciente desconocido',
                    'tipo' => 'Consulta Médica',
                    'motivo' => $consulta['motivoConsulta'] ?? 'Sin motivo especificado',
                    'fecha' => isset($consulta['fecha']) ? Carbon::parse($consulta['fecha'])->format('d/m/Y H:i') : 'N/A',
                    'fechaRelativa' => isset($consulta['fecha']) ? Carbon::parse($consulta['fecha'])->diffForHumans() : 'N/A',
                ];
            }

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
