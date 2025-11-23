<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

putenv('GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=C:/grpc/roots.pem');

try {
    echo "=== PRUEBA DE DASHBOARD ===" . PHP_EOL . PHP_EOL;
    
    // Probar Pacientes
    $pacienteModel = new App\Models\Paciente();
    $pacientes = $pacienteModel->all();
    echo "✓ Pacientes: " . count($pacientes) . PHP_EOL;
    
    // Probar FichaMedica
    $fichaMedicaModel = new App\Models\FichaMedica();
    $fichas = $fichaMedicaModel->all();
    echo "✓ Fichas Médicas: " . count($fichas) . PHP_EOL;
    
    // Probar Consulta
    $consultaModel = new App\Models\Consulta();
    $consultas = $consultaModel->all();
    echo "✓ Consultas: " . count($consultas) . PHP_EOL;
    
    // Probar Hospitalizacion
    $hospitalizacionModel = new App\Models\Hospitalizacion();
    try {
        $hospitalizaciones = $hospitalizacionModel->findActivas();
        echo "✓ Hospitalizaciones activas: " . count($hospitalizaciones) . PHP_EOL;
    } catch (Exception $e) {
        echo "⚠ Hospitalizaciones: No hay registros o error - " . $e->getMessage() . PHP_EOL;
    }
    
    // Probar OrdenExamen
    $ordenExamenModel = new App\Models\OrdenExamen();
    try {
        $ordenes = $ordenExamenModel->findByEstado('pendiente');
        echo "✓ Órdenes de examen pendientes: " . count($ordenes) . PHP_EOL;
    } catch (Exception $e) {
        echo "⚠ Órdenes de examen: No hay registros o error - " . $e->getMessage() . PHP_EOL;
    }
    
    echo PHP_EOL . "=== RESULTADO: CONEXIÓN OK ===" . PHP_EOL;
    
    // Mostrar ejemplo de datos
    if (count($pacientes) > 0) {
        echo PHP_EOL . "Ejemplo de paciente:" . PHP_EOL;
        $primer = $pacientes[0];
        echo "  - Nombre: " . ($primer['nombre'] ?? 'N/A') . " " . ($primer['apellido'] ?? 'N/A') . PHP_EOL;
        echo "  - RUT: " . ($primer['rut'] ?? 'N/A') . PHP_EOL;
    }
    
} catch (Exception $e) {
    echo PHP_EOL . "✗ ERROR: " . $e->getMessage() . PHP_EOL;
    echo "Archivo: " . $e->getFile() . ":" . $e->getLine() . PHP_EOL;
    exit(1);
}
