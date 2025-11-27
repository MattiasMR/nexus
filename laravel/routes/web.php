<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\WebPayController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\UsuarioController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use Laravel\Fortify\Features;

// ============================================
// RUTAS PÚBLICAS (NO AUTENTICADAS)
// ============================================

Route::get('/', function () {
    return redirect()->route('login');
})->name('home');

// Rutas de autenticación
Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [LoginController::class, 'login']);
});

Route::post('/logout', [LoginController::class, 'logout'])
    ->middleware('auth')
    ->name('logout');

// ============================================
// RUTAS PROTEGIDAS (SOLO ADMIN)
// ============================================

Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    // Rutas de gestión de usuarios
    Route::get('/usuarios', [UsuarioController::class, 'index'])->name('usuarios.index');
    Route::get('/usuarios/crear', [UsuarioController::class, 'create'])->name('usuarios.create');
    Route::post('/usuarios', [UsuarioController::class, 'store'])->name('usuarios.store');
    Route::get('/usuarios/{id}', [UsuarioController::class, 'show'])->name('usuarios.show');
    Route::put('/usuarios/{id}', [UsuarioController::class, 'update'])->name('usuarios.update');
    Route::put('/usuarios/{id}/password', [UsuarioController::class, 'updatePassword'])->name('usuarios.password');
    Route::post('/usuarios/{id}/password-reset', [UsuarioController::class, 'sendPasswordReset'])->name('usuarios.password-reset');
    Route::put('/usuarios/{id}/permissions', [UsuarioController::class, 'updatePermissions'])->name('usuarios.permissions');
    Route::post('/usuarios/{id}/verify-email', [UsuarioController::class, 'verifyEmail'])->name('usuarios.verify-email');
    Route::post('/usuarios/{id}/toggle-status', [UsuarioController::class, 'toggleStatus'])->name('usuarios.toggle-status');
    Route::delete('/usuarios/{id}', [UsuarioController::class, 'destroy'])->name('usuarios.destroy');
    
    // Rutas de compra de bonos
    Route::get('/comprar-bono', [WebPayController::class, 'showForm'])->name('comprar-bono');
    Route::post('/comprar-bono/iniciar', [WebPayController::class, 'iniciarTransaccion'])->name('comprar-bono.iniciar');
    
    // Ruta de debug para ver datos del dashboard
    Route::get('/debug-dashboard', function () {
        putenv('GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=C:/grpc/roots.pem');
        
        $controller = new DashboardController();
        $response = $controller->index();
        
        return response()->json($response->toResponse(request())->getData());
    });

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
});

// ============================================
// RUTAS PÚBLICAS WEBPAY (SIN AUTENTICACIÓN)
// ============================================

// Rutas públicas para confirmación de WebPay (sin auth porque Transbank redirige aquí)
Route::get('/comprar-bono/confirmar', [WebPayController::class, 'confirmarTransaccion'])->name('comprar-bono.confirmar');
Route::post('/comprar-bono/confirmar', [WebPayController::class, 'confirmarTransaccion']);
Route::get('/comprar-bono/confirmar', [WebPayController::class, 'confirmarTransaccion'])->name('comprar-bono.confirmar');
Route::post('/comprar-bono/confirmar', [WebPayController::class, 'confirmarTransaccion']);
Route::get('/comprar-bono/descargar-comprobante', [WebPayController::class, 'descargarComprobante'])->name('webpay.descargar');
Route::get('/comprar-bono/descargar-comprobante-html', [WebPayController::class, 'descargarComprobantePDF'])->name('webpay.descargar.html');

require __DIR__.'/settings.php';
