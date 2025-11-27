<?php

namespace App\Providers;

use App\Auth\FirebaseGuard;
use App\Auth\FirestoreUserProvider;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Registrar el User Provider personalizado para Firestore
        Auth::provider('firestore', function ($app, array $config) {
            return new FirestoreUserProvider();
        });

        // Registrar el Guard personalizado para Firebase Authentication
        Auth::extend('firebase', function ($app, $name, array $config) {
            return new FirebaseGuard(
                Auth::createUserProvider($config['provider']),
                $app['request']
            );
        });
    }
}
