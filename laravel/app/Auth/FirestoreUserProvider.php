<?php

namespace App\Auth;

use App\Models\Usuario;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\UserProvider;
use Illuminate\Support\Str;

class FirestoreUserProvider implements UserProvider
{
    protected Usuario $model;

    public function __construct()
    {
        $this->model = new Usuario();
    }

    /**
     * Retrieve a user by their unique identifier.
     */
    public function retrieveById($identifier): ?Authenticatable
    {
        try {
            $userData = $this->model->findByFirebaseUid($identifier);
            
            if (!$userData) {
                return null;
            }

            return Usuario::fromArray($userData);
        } catch (\Exception $e) {
            logger()->error("Error retrieving user by ID {$identifier}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Retrieve a user by their unique identifier and "remember me" token.
     */
    public function retrieveByToken($identifier, $token): ?Authenticatable
    {
        // Firebase Authentication no usa remember tokens de esta manera
        // Retornamos el usuario solo por ID
        return $this->retrieveById($identifier);
    }

    /**
     * Update the "remember me" token for the given user in storage.
     */
    public function updateRememberToken(Authenticatable $user, $token): void
    {
        // Firebase Authentication maneja los tokens automáticamente
        // No necesitamos implementar esto
    }

    /**
     * Retrieve a user by the given credentials.
     */
    public function retrieveByCredentials(array $credentials): ?Authenticatable
    {
        if (empty($credentials['email'])) {
            return null;
        }

        try {
            $userData = $this->model->findByEmail($credentials['email']);
            
            if (!$userData) {
                return null;
            }

            return Usuario::fromArray($userData);
        } catch (\Exception $e) {
            logger()->error("Error retrieving user by credentials: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Validate a user against the given credentials.
     */
    public function validateCredentials(Authenticatable $user, array $credentials): bool
    {
        // La validación de credenciales se hace en Firebase Authentication
        // Este método se llama después de que Firebase ya validó las credenciales
        
        // Verificamos que el email coincida
        if (isset($credentials['email'])) {
            $userEmail = $user->getAttribute('email');
            return $userEmail === $credentials['email'];
        }

        return false;
    }

    /**
     * Rehash the user's password if required and supported.
     */
    public function rehashPasswordIfRequired(Authenticatable $user, array $credentials, bool $force = false): void
    {
        // Firebase Authentication maneja el hashing de contraseñas
        // No necesitamos implementar esto
    }
}
