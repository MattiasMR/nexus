<?php

use App\Http\Controllers\DashboardController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use Laravel\Fortify\Features;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canRegister' => Features::enabled(Features::registration()),
    ]);
})->name('home');

Route::get('dashboard', [DashboardController::class, 'index'])
    ->middleware(['auth', 'verified'])
    ->name('dashboard');

// Ruta de prueba simple para verificar Firebase
Route::get('/test-firebase-simple', function () {
    try {
        return response()->json([
            'success' => true,
            'message' => 'Ruta funcionando',
            'php_version' => PHP_VERSION,
            'extensions' => [
                'grpc' => extension_loaded('grpc'),
                'sodium' => extension_loaded('sodium'),
            ],
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'error' => $e->getMessage(),
        ], 500);
    }
});

// Ruta de prueba para Firebase
Route::get('/test-firebase', function () {
    try {
        // Verificar si gRPC está disponible
        if (!extension_loaded('grpc')) {
            return response()->json([
                'success' => false,
                'error' => 'gRPC extension not available',
                'message' => 'Firestore requires the gRPC PHP extension which is not available in Herd Lite.',
                'solution' => 'Use the Ionic/Flutter app to access Firestore data, or install PHP with gRPC extension.',
                'php_info' => [
                    'version' => PHP_VERSION,
                    'extensions' => get_loaded_extensions(),
                ],
            ], 503);
        }
        
        $paciente = new \App\Models\Paciente();
        $todos = $paciente->all();
        
        return response()->json([
            'success' => true,
            'message' => 'Conexión a Firebase exitosa',
            'total_pacientes' => count($todos),
            'pacientes' => $todos,
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString(),
        ], 500);
    }
});

require __DIR__.'/settings.php';
