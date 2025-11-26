<?php

namespace App\Auth;

use App\Models\Usuario;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Guard;
use Illuminate\Contracts\Auth\StatefulGuard;
use Illuminate\Contracts\Auth\UserProvider;
use Illuminate\Http\Request;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class FirebaseGuard implements StatefulGuard
{
    protected ?Authenticatable $user = null;
    protected UserProvider $provider;
    protected Request $request;
    protected FirebaseAuth $firebaseAuth;

    public function __construct(UserProvider $provider, Request $request)
    {
        $this->provider = $provider;
        $this->request = $request;
        $this->firebaseAuth = app(FirebaseAuth::class);
    }

    /**
     * Determine if the current user is authenticated.
     */
    public function check(): bool
    {
        return !is_null($this->user());
    }

    /**
     * Determine if the current user is a guest.
     */
    public function guest(): bool
    {
        return !$this->check();
    }

    /**
     * Get the currently authenticated user.
     */
    public function user(): ?Authenticatable
    {
        if (!is_null($this->user)) {
            return $this->user;
        }

        // Intentar obtener el usuario de la sesión
        $userId = $this->request->session()->get('firebase_user_id');
        
        if ($userId) {
            $this->user = $this->provider->retrieveById($userId);
            return $this->user;
        }

        // Intentar validar token JWT de Firebase
        $token = $this->getTokenFromRequest();
        
        if ($token) {
            try {
                $verifiedIdToken = $this->firebaseAuth->verifyIdToken($token);
                $uid = $verifiedIdToken->claims()->get('sub');
                
                $this->user = $this->provider->retrieveById($uid);
                
                if ($this->user) {
                    // Guardar en sesión
                    $this->request->session()->put('firebase_user_id', $uid);
                }
                
                return $this->user;
            } catch (\Exception $e) {
                logger()->error('Error verificando token Firebase: ' . $e->getMessage());
                return null;
            }
        }

        return null;
    }

    /**
     * Get the ID for the currently authenticated user.
     */
    public function id(): mixed
    {
        if ($user = $this->user()) {
            return $user->getAuthIdentifier();
        }

        return null;
    }

    /**
     * Validate a user's credentials.
     */
    public function validate(array $credentials = []): bool
    {
        if (empty($credentials['email']) || empty($credentials['password'])) {
            return false;
        }

        try {
            $signInResult = $this->firebaseAuth->signInWithEmailAndPassword(
                $credentials['email'],
                $credentials['password']
            );

            return !is_null($signInResult);
        } catch (\Exception $e) {
            logger()->error('Error validando credenciales: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Attempt to authenticate a user using the given credentials.
     */
    public function attempt(array $credentials = [], $remember = false)
    {
        try {
            // Autenticar con Firebase Authentication
            $signInResult = $this->firebaseAuth->signInWithEmailAndPassword(
                $credentials['email'],
                $credentials['password']
            );

            $firebaseUser = $signInResult->firebaseUserId();
            
            // Buscar usuario en Firestore
            $user = $this->provider->retrieveById($firebaseUser);

            if (!$user) {
                logger()->warning("Usuario autenticado en Firebase pero no encontrado en Firestore: {$firebaseUser}");
                return false;
            }

            // Verificar que el usuario esté activo
            $userData = $user->getAttributes();
            if (isset($userData['activo']) && !$userData['activo']) {
                logger()->warning("Intento de login con usuario inactivo: {$credentials['email']}");
                return false;
            }

            // Verificar rol si se especificó
            if (isset($credentials['rol'])) {
                if (!isset($userData['rol']) || $userData['rol'] !== $credentials['rol']) {
                    logger()->warning("Usuario {$credentials['email']} no tiene el rol requerido: {$credentials['rol']}");
                    return false;
                }
            }

            // Establecer el usuario autenticado
            $this->setUser($user);

            // Guardar en sesión
            $this->request->session()->put('firebase_user_id', $firebaseUser);
            $this->request->session()->put('firebase_token', $signInResult->idToken());

            // Actualizar último acceso
            $usuarioModel = new Usuario();
            $usuarioModel->updateLastAccess($firebaseUser);

            return true;

        } catch (\Kreait\Firebase\Exception\Auth\InvalidPassword $e) {
            logger()->warning("Contraseña incorrecta para: {$credentials['email']}");
            return false;
        } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
            logger()->warning("Usuario no encontrado en Firebase Auth: {$credentials['email']}");
            return false;
        } catch (\Exception $e) {
            logger()->error('Error en attempt: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Set the current user.
     */
    public function setUser(Authenticatable $user): void
    {
        $this->user = $user;
    }

    /**
     * Log the user out of the application.
     */
    public function logout(): void
    {
        $this->user = null;
        
        $this->request->session()->forget('firebase_user_id');
        $this->request->session()->forget('firebase_token');
        $this->request->session()->invalidate();
        $this->request->session()->regenerateToken();
    }

    /**
     * Get the token from the request.
     */
    protected function getTokenFromRequest(): ?string
    {
        // Intentar obtener de header Authorization
        $header = $this->request->header('Authorization');
        
        if ($header && str_starts_with($header, 'Bearer ')) {
            return substr($header, 7);
        }

        // Intentar obtener de sesión
        return $this->request->session()->get('firebase_token');
    }

    /**
     * Determine if the guard has a user instance.
     */
    public function hasUser(): bool
    {
        return !is_null($this->user);
    }

    /**
     * Log a user into the application without sessions or cookies.
     */
    public function once(array $credentials = []): bool
    {
        if ($this->validate($credentials)) {
            $user = $this->provider->retrieveByCredentials($credentials);
            $this->setUser($user);
            return true;
        }

        return false;
    }

    /**
     * Log the given user ID into the application without sessions or cookies.
     */
    public function onceUsingId($id): bool
    {
        if (!is_null($user = $this->provider->retrieveById($id))) {
            $this->setUser($user);
            return true;
        }

        return false;
    }

    /**
     * Attempt to authenticate using HTTP Basic Auth.
     */
    public function basic(string $field = 'email', array $extraConditions = []): ?\Symfony\Component\HttpFoundation\Response
    {
        return null;
    }

    /**
     * Perform a stateless HTTP Basic login attempt.
     */
    public function onceBasic(string $field = 'email', array $extraConditions = []): ?\Symfony\Component\HttpFoundation\Response
    {
        return null;
    }

    /**
     * Attempt to authenticate a user with credentials and "remember me".
     */
    public function login(Authenticatable $user, $remember = false)
    {
        $this->setUser($user);
        
        // Guardar en sesión
        $userId = $user->getAuthIdentifier();
        $this->request->session()->put('firebase_user_id', $userId);
        $this->request->session()->regenerate();
    }

    /**
     * Log the given user ID into the application.
     */
    public function loginUsingId($id, $remember = false)
    {
        if (!is_null($user = $this->provider->retrieveById($id))) {
            $this->login($user, $remember);
            return $user;
        }

        return false;
    }

    /**
     * Determine if the user was authenticated via "remember me" cookie.
     */
    public function viaRemember(): bool
    {
        return false;
    }
}
