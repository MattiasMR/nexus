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

            // Configurar variables de entorno para gRPC
            putenv('GOOGLE_APPLICATION_CREDENTIALS=' . $credentialsPath);
            putenv('SUPPRESS_GCLOUD_CREDS_WARNING=true');
            
            return (new Factory)
                ->withServiceAccount($credentialsPath);
        });

        // Register Firebase Firestore - usar REST en Windows para evitar recursión infinita
        $this->app->singleton(Firestore::class, function ($app) {
            try {
                $credentialsPath = storage_path('app/firebase-credentials.json');
                
                // En Windows, usar REST transport para evitar recursión infinita de gRPC
                $isWindows = strtoupper(substr(PHP_OS, 0, 3)) === 'WIN';
                
                $config = [
                    'keyFilePath' => $credentialsPath,
                    'projectId' => config('firebase.project_id', 'nexus-68994'),
                ];
                
                if ($isWindows) {
                    // Forzar REST transport en Windows
                    $config['transport'] = 'rest';
                }
                
                $firestoreClient = new FirestoreClient($config);
                
                // Crear un wrapper compatible con Kreait
                return new class($firestoreClient) implements Firestore {
                    private FirestoreClient $client;
                    
                    public function __construct(FirestoreClient $client) {
                        $this->client = $client;
                    }
                    
                    public function database(): FirestoreClient {
                        return $this->client;
                    }
                };
                
            } catch (\Exception $e) {
                logger()->error('Failed to initialize Firestore: ' . $e->getMessage());
                throw new \Exception('Firestore initialization failed: ' . $e->getMessage());
            }
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
