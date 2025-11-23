<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\WebPayController;
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

// Ruta de debug para ver datos del dashboard
Route::get('/debug-dashboard', function () {
    putenv('GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=C:/grpc/roots.pem');
    
    $controller = new DashboardController();
    $response = $controller->index();
    
    return response()->json($response->toResponse(request())->getData());
})->middleware(['auth', 'verified']);

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

// Ruta de prueba para Firebase/Firestore
Route::get('/test-firebase', function () {
    try {
        // Obtener información sobre extensiones disponibles
        $grpcLoaded = extension_loaded('grpc');
        $sodiumLoaded = extension_loaded('sodium');
        
        // Intentar conectar a Firestore
        $paciente = new \App\Models\Paciente();
        $todos = $paciente->all();
        
        return response()->json([
            'success' => true,
            'message' => 'Conexión a Firestore exitosa',
            'connection_type' => $grpcLoaded ? 'gRPC (optimizado)' : 'REST API',
            'total_pacientes' => count($todos),
            'pacientes' => $todos,
            'php_info' => [
                'version' => PHP_VERSION,
                'grpc_available' => $grpcLoaded,
                'sodium_available' => $sodiumLoaded,
            ],
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'error' => $e->getMessage(),
            'trace' => config('app.debug') ? $e->getTraceAsString() : null,
            'php_info' => [
                'version' => PHP_VERSION,
                'grpc_available' => extension_loaded('grpc'),
                'sodium_available' => extension_loaded('sodium'),
            ],
            'help' => 'Si ves este error, revisa INSTALAR_GRPC.md para instrucciones de instalación.',
        ], 500);
    }
});

// ============================================
// Rutas de WebPay Plus - Compra de Bonos
// ============================================
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/comprar-bono', [WebPayController::class, 'showForm'])->name('webpay.form');
    Route::post('/comprar-bono/iniciar', [WebPayController::class, 'iniciarTransaccion'])->name('webpay.iniciar');
    Route::get('/comprar-bono/descargar-comprobante', [WebPayController::class, 'descargarComprobante'])->name('webpay.descargar');
    Route::get('/comprar-bono/descargar-comprobante-html', [WebPayController::class, 'descargarComprobantePDF'])->name('webpay.descargar.html');
});

// Rutas públicas para confirmación de WebPay (sin auth porque Transbank redirige aquí)
Route::get('/comprar-bono/confirmar', [WebPayController::class, 'confirmarTransaccion'])->name('webpay.confirmar');
Route::post('/comprar-bono/confirmar', [WebPayController::class, 'confirmarTransaccion'])->name('webpay.confirmar.post');

require __DIR__.'/settings.php';
