<?php

namespace App\Http\Controllers;

use App\Models\Paciente;
use App\Models\Consulta;
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
            $pacienteModel = new Paciente();
            $consultaModel = new Consulta();

            // Obtener todos los pacientes
            $pacientes = $pacienteModel->all();
            $totalPacientes = count($pacientes);

            // Contar alertas críticas (pacientes con alertas de alta severidad)
            $alertasCriticas = 0;
            foreach ($pacientes as $paciente) {
                if (isset($paciente['alertasMedicas'])) {
                    foreach ($paciente['alertasMedicas'] as $alerta) {
                        if (in_array($alerta['severidad'] ?? '', ['critica', 'alta'])) {
                            $alertasCriticas++;
                        }
                    }
                }
            }

            // Estadísticas
            $stats = [
                [
                    'value' => (string)$totalPacientes,
                    'title' => 'Pacientes Activos',
                    'sub' => 'Total en el sistema',
                    'icon' => 'bi-people',
                    'color' => 'primary'
                ],
                [
                    'value' => '0',
                    'title' => 'Citas Hoy',
                    'sub' => 'Pendientes',
                    'icon' => 'bi-calendar-check',
                    'color' => 'success'
                ],
                [
                    'value' => '0',
                    'title' => 'Exámenes Pendientes',
                    'sub' => 'Por revisar',
                    'icon' => 'bi-flask',
                    'color' => 'warning'
                ],
                [
                    'value' => (string)$alertasCriticas,
                    'title' => 'Alertas Críticas',
                    'sub' => 'Requieren atención',
                    'icon' => 'bi-exclamation-triangle',
                    'color' => 'danger'
                ],
            ];

            // Recopilar alertas para el dashboard
            $alertas = [];
            foreach ($pacientes as $paciente) {
                if (isset($paciente['alertasMedicas'])) {
                    foreach ($paciente['alertasMedicas'] as $alerta) {
                        $alertas[] = [
                            'id' => uniqid(),
                            'pacienteNombre' => $paciente['nombreCompleto'] ?? ($paciente['nombre'] . ' ' . $paciente['apellido']),
                            'tipo' => $this->mapAlertType($alerta['tipo'] ?? 'otro'),
                            'severidad' => $alerta['severidad'] ?? 'media',
                            'descripcion' => $alerta['descripcion'] ?? '',
                            'fecha' => isset($alerta['fechaRegistro']) ? $alerta['fechaRegistro']->toIso8601String() : now()->toIso8601String(),
                        ];
                    }
                }
            }

            // Ordenar por severidad y fecha
            usort($alertas, function($a, $b) {
                $severityOrder = ['critica' => 0, 'alta' => 1, 'media' => 2, 'baja' => 3];
                $severityCompare = ($severityOrder[$a['severidad']] ?? 4) - ($severityOrder[$b['severidad']] ?? 4);
                
                if ($severityCompare !== 0) {
                    return $severityCompare;
                }
                
                return strtotime($b['fecha']) - strtotime($a['fecha']);
            });

            // Limitar a las primeras 10 alertas
            $alertas = array_slice($alertas, 0, 10);

            return Inertia::render('Dashboard', [
                'stats' => $stats,
                'alertas' => $alertas,
                'isLoading' => false,
            ]);

        } catch (\Exception $e) {
            // Si hay error con Firebase, mostrar datos de ejemplo
            return $this->fallbackDashboard($e->getMessage());
        }
    }

    /**
     * Mapear tipo de alerta de Firebase a tipo de dashboard
     */
    private function mapAlertType(string $tipo): string
    {
        $mapping = [
            'alergia' => 'medicamento',
            'enfermedad_cronica' => 'cita',
            'medicamento_critico' => 'medicamento',
            'otro' => 'examen',
        ];

        return $mapping[$tipo] ?? 'examen';
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
                'sub' => 'Firebase no disponible',
                'icon' => 'bi-people',
                'color' => 'primary'
            ],
            [
                'value' => '0',
                'title' => 'Citas Hoy',
                'sub' => 'Firebase no disponible',
                'icon' => 'bi-calendar-check',
                'color' => 'success'
            ],
            [
                'value' => '0',
                'title' => 'Exámenes Pendientes',
                'sub' => 'Firebase no disponible',
                'icon' => 'bi-flask',
                'color' => 'warning'
            ],
            [
                'value' => '0',
                'title' => 'Alertas Críticas',
                'sub' => 'Firebase no disponible',
                'icon' => 'bi-exclamation-triangle',
                'color' => 'danger'
            ],
        ];

        return Inertia::render('Dashboard', [
            'stats' => $stats,
            'alertas' => [],
            'isLoading' => false,
            'error' => 'Error de conexión con Firebase: ' . $error,
        ]);
    }
}

