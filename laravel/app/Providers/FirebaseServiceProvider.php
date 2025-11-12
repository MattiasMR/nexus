<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Contract\Firestore;
use Kreait\Firebase\Contract\Auth;
use Kreait\Firebase\Contract\Storage;
use Google\Cloud\Firestore\FirestoreClient;

class FirebaseServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->singleton(Factory::class, function ($app) {
            $credentialsPath = storage_path('app/firebase-credentials.json');
            
            if (!file_exists($credentialsPath)) {
                throw new \Exception("Firebase credentials file not found at: {$credentialsPath}");
            }

            return (new Factory)
                ->withServiceAccount($credentialsPath);
        });

        // NOTA: Firestore requiere la extensión gRPC de PHP para funcionar
        // Como Herd Lite no incluye gRPC, Firestore está deshabilitado temporalmente
        // Para habilitarlo, necesitas instalar PHP con la extensión gRPC
        // 
        // Mientras tanto, puedes usar la app Ionic/Flutter para acceder a Firestore
        // o instalar un PHP completo con extensiones
        
        $this->app->singleton(Firestore::class, function ($app) {
            // Retornar null cuando gRPC no está disponible
            if (!extension_loaded('grpc')) {
                return null;
            }
            
            return $app->make(Factory::class)->createFirestore();
        });

        // Register Firebase Auth
        $this->app->singleton(Auth::class, function ($app) {
            return $app->make(Factory::class)->createAuth();
        });

        // Register Firebase Storage
        $this->app->singleton(Storage::class, function ($app) {
            return $app->make(Factory::class)->createStorage();
        });
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
