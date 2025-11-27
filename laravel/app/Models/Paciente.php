<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

/**
 * Modelo Paciente
 * 
 * Representa los datos médicos específicos de un paciente.
 * NO duplica datos de autenticación (email, nombre, rut, telefono).
 * 
 * Estructura:
 * - id: ID único del paciente
 * - idUsuario: Referencia a usuarios.id (OBLIGATORIO - todo paciente debe tener usuario)
 * - fechaNacimiento: Fecha de nacimiento
 * - grupoSanguineo: Tipo de sangre (A+, A-, B+, B-, AB+, AB-, O+, O-)
 * - alergias: Array de alergias
 * - enfermedadesCronicas: Array de enfermedades crónicas
 * - medicamentosActuales: Array de medicamentos que toma actualmente
 * - contactoEmergencia: {nombre, telefono, relacion}
 * - prevision: FONASA, ISAPRE, etc.
 * - numeroFicha: Número de ficha médica
 * - observaciones: Notas adicionales
 * - createdAt, updatedAt: Timestamps
 * 
 * Para obtener datos del usuario (nombre, email, rut, telefono):
 * Se debe hacer join con la colección 'usuarios' usando idUsuario
 */
class Paciente
{
    protected Firestore $firestore;
    protected string $collection = 'pacientes';

    public function __construct()
    {
        $this->firestore = app(Firestore::class);
    }

    /**
     * Obtener todos los pacientes
     */
    public function all(): array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->documents();

            $pacientes = [];
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    $pacientes[] = $this->formatDates($data);
                }
            }

            return $pacientes;
        } catch (\Exception $e) {
            logger()->error('Error fetching all patients from Firestore: ' . $e->getMessage());
            throw new \Exception('No se pudo conectar con Firestore. Verifica tu conexión a Internet y las credenciales de Firebase.');
        }
    }

    /**
     * Buscar paciente por ID
     */
    public function find(string $id): ?array
    {
        $document = $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->snapshot();

        if ($document->exists()) {
            $data = $document->data();
            $data['id'] = $document->id();
            return $this->formatDates($data);
        }

        return null;
    }

    /**
     * Buscar paciente por RUT (deprecated - usar Usuario::findByRut)
     * 
     * @deprecated Use Usuario::findByRut() en su lugar
     */
    public function findByRut(string $rut): ?array
    {
        // Buscar en usuarios y luego obtener el paciente vinculado
        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->findByRut($rut);
        
        if (!$usuario || !isset($usuario['idPaciente'])) {
            return null;
        }
        
        return $this->find($usuario['idPaciente']);
    }

    /**
     * Buscar paciente por ID de usuario
     */
    public function findByUsuarioId(string $idUsuario): ?array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idUsuario', '=', $idUsuario)
            ->limit(1)
            ->documents();

        foreach ($documents as $document) {
            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                return $this->formatDates($data);
            }
        }

        return null;
    }

    /**
     * Obtener paciente con datos de usuario
     * Retorna paciente + datos del usuario en una sola estructura
     */
    public function findWithUser(string $id): ?array
    {
        $paciente = $this->find($id);
        
        if (!$paciente || !isset($paciente['idUsuario'])) {
            return $paciente;
        }

        // Obtener datos del usuario
        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->find($paciente['idUsuario']);

        if ($usuario) {
            // Agregar datos del usuario al paciente
            $paciente['usuario'] = [
                'id' => $usuario['id'],
                'displayName' => $usuario['displayName'] ?? '',
                'email' => $usuario['email'] ?? '',
                'rut' => $usuario['rut'] ?? '',
                'telefono' => $usuario['telefono'] ?? '',
                'photoURL' => $usuario['photoURL'] ?? null,
            ];
        }

        return $paciente;
    }

    /**
     * Obtener todos los pacientes con datos de usuario
     */
    public function allWithUsers(): array
    {
        $pacientes = $this->all();
        $usuarioModel = new Usuario();

        return array_map(function($paciente) use ($usuarioModel) {
            if (isset($paciente['idUsuario'])) {
                $usuario = $usuarioModel->find($paciente['idUsuario']);
                if ($usuario) {
                    $paciente['usuario'] = [
                        'id' => $usuario['id'],
                        'displayName' => $usuario['displayName'] ?? '',
                        'email' => $usuario['email'] ?? '',
                        'rut' => $usuario['rut'] ?? '',
                        'telefono' => $usuario['telefono'] ?? '',
                        'photoURL' => $usuario['photoURL'] ?? null,
                    ];
                }
            }
            return $paciente;
        }, $pacientes);
    }

    /**
     * Crear un nuevo paciente
     * 
     * IMPORTANTE: idUsuario es OBLIGATORIO
     * El usuario debe existir previamente en la colección 'usuarios'
     */
    public function create(array $data): string
    {
        // Validar que idUsuario esté presente
        if (empty($data['idUsuario'])) {
            throw new \Exception('El campo idUsuario es obligatorio para crear un paciente');
        }

        // Validar que el usuario exista
        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->find($data['idUsuario']);
        
        if (!$usuario) {
            throw new \Exception("El usuario con ID {$data['idUsuario']} no existe");
        }

        // Validar que el usuario no tenga ya un paciente vinculado
        $existingPaciente = $this->findByUsuarioId($data['idUsuario']);
        if ($existingPaciente) {
            throw new \Exception("El usuario {$data['idUsuario']} ya tiene un paciente vinculado");
        }

        $data['createdAt'] = now()->toDateTime();
        $data['updatedAt'] = now()->toDateTime();

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        // Actualizar el usuario con el idPaciente
        $usuarioModel->update($data['idUsuario'], [
            'idPaciente' => $docRef->id()
        ]);

        return $docRef->id();
    }

    /**
     * Actualizar paciente
     */
    public function update(string $id, array $data): bool
    {
        $data['updatedAt'] = now()->toDateTime();
        
        // No permitir cambiar idUsuario después de creado
        if (isset($data['idUsuario'])) {
            unset($data['idUsuario']);
            logger()->warning("Intento de cambiar idUsuario en paciente {$id} - campo ignorado");
        }

        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->set($data, ['merge' => true]);

        return true;
    }

    /**
     * Eliminar paciente
     * También elimina la referencia en el usuario
     */
    public function delete(string $id): bool
    {
        // Obtener el paciente para saber su idUsuario
        $paciente = $this->find($id);
        
        if ($paciente && isset($paciente['idUsuario'])) {
            // Eliminar la referencia idPaciente del usuario
            $usuarioModel = new Usuario();
            try {
                $usuarioModel->update($paciente['idUsuario'], [
                    'idPaciente' => null
                ]);
            } catch (\Exception $e) {
                logger()->warning("No se pudo actualizar usuario al eliminar paciente: " . $e->getMessage());
            }
        }

        // Eliminar el paciente
        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->delete();

        return true;
    }

    /**
     * Buscar pacientes por nombre (deprecated - usar búsqueda en usuarios)
     * 
     * @deprecated Buscar en la colección 'usuarios' con rol='paciente'
     */
    public function search(string $query): array
    {
        // Para buscar pacientes por nombre, email o RUT,
        // ahora se debe buscar en la colección 'usuarios'
        $usuarioModel = new Usuario();
        $allUsuarios = $usuarioModel->getByRole('paciente');
        
        // Filtrar por query
        $usuariosFiltrados = array_filter($allUsuarios, function($usuario) use ($query) {
            $queryLower = strtolower($query);
            $nombre = strtolower($usuario['displayName'] ?? '');
            $email = strtolower($usuario['email'] ?? '');
            $rut = strtolower($usuario['rut'] ?? '');
            
            return str_contains($nombre, $queryLower) || 
                   str_contains($email, $queryLower) ||
                   str_contains($rut, $queryLower);
        });

        // Obtener los pacientes completos
        $pacientes = [];
        foreach ($usuariosFiltrados as $usuario) {
            if (isset($usuario['idPaciente'])) {
                $paciente = $this->find($usuario['idPaciente']);
                if ($paciente) {
                    $paciente['usuario'] = [
                        'displayName' => $usuario['displayName'] ?? '',
                        'email' => $usuario['email'] ?? '',
                        'rut' => $usuario['rut'] ?? '',
                        'telefono' => $usuario['telefono'] ?? '',
                    ];
                    $pacientes[] = $paciente;
                }
            }
        }

        return $pacientes;
    }

    /**
     * Formatear fechas de Firestore a Carbon
     */
    protected function formatDates(array $data): array
    {
        $dateFields = ['fechaNacimiento', 'createdAt', 'updatedAt'];
        
        foreach ($dateFields as $field) {
            if (isset($data[$field]) && is_object($data[$field])) {
                // Convertir Firestore Timestamp a Carbon
                $data[$field] = Carbon::parse($data[$field]);
            }
        }

        // Formatear fechas en alertas médicas
        if (isset($data['alertasMedicas']) && is_array($data['alertasMedicas'])) {
            foreach ($data['alertasMedicas'] as &$alerta) {
                if (isset($alerta['fechaRegistro']) && is_object($alerta['fechaRegistro'])) {
                    $alerta['fechaRegistro'] = Carbon::parse($alerta['fechaRegistro']);
                }
            }
        }

        return $data;
    }
}
