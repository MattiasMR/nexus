<?php

namespace App\Models;

use Kreait\Firebase\Contract\Firestore;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\Hash;
use JsonSerializable;

class Usuario implements Authenticatable, JsonSerializable
{
    protected Firestore $firestore;
    protected string $collection = 'usuarios';
    protected array $attributes = [];
    protected ?string $rememberToken = null;

    public function __construct(array $attributes = [])
    {
        $this->firestore = app(Firestore::class);
        $this->attributes = $attributes;
    }

    /**
     * Obtener todos los usuarios
     */
    public function all(): array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->documents();

            $usuarios = [];
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    $usuarios[] = $data;
                }
            }

            return $usuarios;
        } catch (\Exception $e) {
            logger()->error('Error obteniendo usuarios: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Buscar usuario por ID
     */
    public function find(string $id): ?array
    {
        try {
            $document = $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->snapshot();

            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                return $data;
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando usuario {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Buscar usuario por email
     */
    public function findByEmail(string $email): ?array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('email', '=', $email)
                ->documents();

            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    return $data;
                }
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando usuario por email {$email}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Crear un nuevo usuario
     * 
     * Campos requeridos: email, displayName, rut, rol
     * Campos opcionales: telefono, photoURL, activo
     * 
     * IMPORTANTE: 
     * - El RUT debe ser único en el sistema
     * - El email debe ser único en el sistema
     * - Si rol = 'paciente', se puede vincular con idPaciente (opcional)
     * - Si rol = 'profesional', se puede vincular con idProfesional (opcional)
     */
    public static function create(array $data): array
    {
        $instance = new self();
        
        try {
            // Validar campos requeridos
            if (empty($data['email'])) {
                throw new \Exception('El email es requerido');
            }
            if (empty($data['displayName'])) {
                throw new \Exception('El nombre completo es requerido');
            }
            if (empty($data['rut'])) {
                throw new \Exception('El RUT es requerido');
            }
            if (empty($data['rol'])) {
                throw new \Exception('El rol es requerido');
            }

            // Validar que el email sea único
            if ($instance->emailExists($data['email'])) {
                throw new \Exception("El email {$data['email']} ya está registrado");
            }

            // Validar que el RUT sea único
            if ($instance->rutExists($data['rut'])) {
                throw new \Exception("El RUT {$data['rut']} ya está registrado");
            }

            // Agregar timestamps
            $now = new \DateTime();
            $data['createdAt'] = $now;
            $data['updatedAt'] = $now;
            $data['ultimoAcceso'] = $now;

            // Establecer activo por defecto
            if (!isset($data['activo'])) {
                $data['activo'] = true;
            }

            // Crear el documento
            $docRef = $instance->firestore
                ->database()
                ->collection($instance->collection)
                ->add($data);

            // Retornar el usuario creado con su ID
            $data['id'] = $docRef->id();
            return $data;

        } catch (\Exception $e) {
            logger()->error('Error creando usuario: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Actualizar un usuario
     */
    public function update(string $id, array $data): array
    {
        try {
            // Actualizar timestamp
            $data['updatedAt'] = new \DateTime();

            // Validar email único si se está actualizando
            if (isset($data['email'])) {
                $existingUser = $this->findByEmail($data['email']);
                if ($existingUser && $existingUser['id'] !== $id) {
                    throw new \Exception("El email {$data['email']} ya está registrado");
                }
            }

            $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->set($data, ['merge' => true]);

            return $this->find($id);
        } catch (\Exception $e) {
            logger()->error("Error actualizando usuario {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Eliminar un usuario
     */
    public function delete(string $id): bool
    {
        try {
            $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->delete();

            return true;
        } catch (\Exception $e) {
            logger()->error("Error eliminando usuario {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Desactivar usuario (soft delete)
     */
    public function deactivate(string $id): array
    {
        return $this->update($id, ['activo' => false]);
    }

    /**
     * Activar usuario
     */
    public function activate(string $id): array
    {
        return $this->update($id, ['activo' => true]);
    }

    /**
     * Verificar si un email ya existe
     */
    public function emailExists(string $email): bool
    {
        return $this->findByEmail($email) !== null;
    }

    /**
     * Buscar usuario por RUT
     */
    public function findByRut(string $rut): ?array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('rut', '=', $rut)
                ->documents();

            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    return $data;
                }
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando usuario por RUT {$rut}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Verificar si un RUT ya existe
     */
    public function rutExists(string $rut): bool
    {
        return $this->findByRut($rut) !== null;
    }

    /**
     * Buscar usuario vinculado a un paciente
     */
    public function findByPacienteId(string $idPaciente): ?array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('idPaciente', '=', $idPaciente)
                ->limit(1)
                ->documents();

            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    return $data;
                }
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando usuario por idPaciente {$idPaciente}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Buscar usuario vinculado a un profesional
     */
    public function findByProfesionalId(string $idProfesional): ?array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('idProfesional', '=', $idProfesional)
                ->limit(1)
                ->documents();

            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    return $data;
                }
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando usuario por idProfesional {$idProfesional}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Verificar si un paciente ya tiene usuario
     */
    public function pacienteHasUser(string $idPaciente): bool
    {
        return $this->findByPacienteId($idPaciente) !== null;
    }

    /**
     * Verificar si un profesional ya tiene usuario
     */
    public function profesionalHasUser(string $idProfesional): bool
    {
        return $this->findByProfesionalId($idProfesional) !== null;
    }

    /**
     * Actualizar último acceso
     */
    public function updateLastAccess(string $id): void
    {
        try {
            $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->set([
                    'ultimoAcceso' => new \DateTime(),
                    'updatedAt' => new \DateTime(),
                ], ['merge' => true]);
        } catch (\Exception $e) {
            logger()->error("Error actualizando último acceso de usuario {$id}: " . $e->getMessage());
        }
    }

    /**
     * Obtener usuarios por rol
     */
    public function getByRole(string $rol): array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('rol', '=', $rol)
                ->documents();

            $usuarios = [];
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    $usuarios[] = $data;
                }
            }

            return $usuarios;
        } catch (\Exception $e) {
            logger()->error("Error obteniendo usuarios con rol {$rol}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Obtener solo usuarios activos
     */
    public function getActive(): array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('activo', '=', true)
                ->documents();

            $usuarios = [];
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    $usuarios[] = $data;
                }
            }

            return $usuarios;
        } catch (\Exception $e) {
            logger()->error('Error obteniendo usuarios activos: ' . $e->getMessage());
            throw $e;
        }
    }

    // ============================================
    // MÉTODOS DE AUTHENTICATABLE INTERFACE
    // ============================================

    /**
     * Get the name of the unique identifier for the user.
     */
    public function getAuthIdentifierName(): string
    {
        return 'uid';
    }

    /**
     * Get the unique identifier for the user.
     */
    public function getAuthIdentifier(): mixed
    {
        return $this->attributes['id'] ?? null;
    }

    /**
     * Get the password for the user.
     */
    public function getAuthPassword(): string
    {
        return $this->attributes['password'] ?? '';
    }

    /**
     * Get the token value for the "remember me" session.
     */
    public function getRememberToken(): ?string
    {
        return $this->rememberToken;
    }

    /**
     * Set the token value for the "remember me" session.
     */
    public function setRememberToken($value): void
    {
        $this->rememberToken = $value;
    }

    /**
     * Get the column name for the "remember me" token.
     */
    public function getRememberTokenName(): string
    {
        return 'remember_token';
    }

    /**
     * Get the user's auth password (hashed).
     */
    public function getAuthPasswordName(): string
    {
        return 'password';
    }

    // ============================================
    // MÉTODOS ADICIONALES PARA FIREBASE AUTH
    // ============================================

    /**
     * Buscar usuario por Firebase UID
     */
    public function findByFirebaseUid(string $firebaseUid): ?array
    {
        try {
            $document = $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($firebaseUid)
                ->snapshot();

            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                return $data;
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando usuario por Firebase UID {$firebaseUid}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Crear usuario desde Firebase Authentication user
     */
    public static function createFromFirebaseUser(array $firebaseUser): array
    {
        $instance = new self();
        
        try {
            $data = [
                'email' => $firebaseUser['email'] ?? '',
                'displayName' => $firebaseUser['displayName'] ?? $firebaseUser['email'],
                'rol' => $firebaseUser['rol'] ?? 'paciente',
                'activo' => true,
                'firebaseUid' => $firebaseUser['uid'],
            ];

            // Si tiene idPaciente, agregarlo
            if (isset($firebaseUser['idPaciente'])) {
                $data['idPaciente'] = $firebaseUser['idPaciente'];
            }

            // Agregar timestamps
            $now = new \DateTime();
            $data['createdAt'] = $now;
            $data['updatedAt'] = $now;
            $data['ultimoAcceso'] = $now;

            // Crear documento usando el UID de Firebase como ID
            $instance->firestore
                ->database()
                ->collection($instance->collection)
                ->document($firebaseUser['uid'])
                ->set($data);

            $data['id'] = $firebaseUser['uid'];
            return $data;

        } catch (\Exception $e) {
            logger()->error('Error creando usuario desde Firebase: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Actualizar Firebase UID de un usuario existente
     */
    public function updateFirebaseUid(string $id, string $firebaseUid): array
    {
        try {
            $data = ['firebaseUid' => $firebaseUid, 'updatedAt' => new \DateTime()];

            $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->set($data, ['merge' => true]);

            return $this->find($id);
        } catch (\Exception $e) {
            logger()->error("Error actualizando Firebase UID para usuario {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Convertir array de datos a instancia de Usuario
     */
    public static function fromArray(array $data): self
    {
        return new self($data);
    }

    /**
     * Obtener atributo específico
     */
    public function getAttribute(string $key): mixed
    {
        return $this->attributes[$key] ?? null;
    }

    /**
     * Establecer atributo
     */
    public function setAttribute(string $key, mixed $value): void
    {
        $this->attributes[$key] = $value;
    }

    /**
     * Obtener todos los atributos
     */
    public function getAttributes(): array
    {
        return $this->attributes;
    }

    /**
     * Magic method para acceder a atributos como propiedades
     */
    public function __get(string $key): mixed
    {
        // Mapear 'name' a 'displayName' para compatibilidad con User interface
        if ($key === 'name') {
            return $this->attributes['displayName'] ?? $this->attributes['email'] ?? 'Usuario';
        }
        
        // Mapear 'avatar' a 'photoURL'
        if ($key === 'avatar') {
            return $this->attributes['photoURL'] ?? null;
        }
        
        // Mapear 'uid' al id
        if ($key === 'uid') {
            return $this->attributes['id'] ?? null;
        }
        
        return $this->attributes[$key] ?? null;
    }

    /**
     * Magic method para verificar si un atributo existe
     */
    public function __isset(string $key): bool
    {
        return isset($this->attributes[$key]);
    }

    /**
     * Serializar el usuario a JSON para Inertia
     */
    public function jsonSerialize(): array
    {
        return [
            'uid' => $this->attributes['id'] ?? null,
            'name' => $this->attributes['displayName'] ?? $this->attributes['email'] ?? 'Usuario',
            'email' => $this->attributes['email'] ?? null,
            'avatar' => $this->attributes['photoURL'] ?? null,
            'email_verified_at' => $this->attributes['emailVerified'] ?? null,
            'created_at' => $this->attributes['fechaCreacion'] ?? null,
            'updated_at' => $this->attributes['fechaModificacion'] ?? null,
            'rol' => $this->attributes['rol'] ?? null,
            'activo' => $this->attributes['activo'] ?? true,
            'rut' => $this->attributes['rut'] ?? null,
            'telefono' => $this->attributes['telefono'] ?? null,
        ];
    }
}
