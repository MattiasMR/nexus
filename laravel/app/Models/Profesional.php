<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

/**
 * Modelo Profesional
 * 
 * Representa los datos profesionales específicos de un profesional de la salud.
 * NO duplica datos de autenticación (email, nombre, rut, telefono).
 * 
 * Estructura:
 * - id: ID único del profesional
 * - idUsuario: Referencia a usuarios.id (OBLIGATORIO - todo profesional debe tener usuario)
 * - especialidad: Especialidad médica
 * - licenciaMedica: Número de licencia/registro profesional
 * - subespecialidad: Subespecialidad (opcional)
 * - horarioAtencion: Horarios de atención
 * - valorConsulta: Valor de la consulta
 * - tiempoConsulta: Duración promedio de consulta en minutos
 * - experienciaAnios: Años de experiencia
 * - curriculum: Breve descripción profesional
 * - createdAt, updatedAt: Timestamps
 * 
 * Para obtener datos del usuario (nombre, email, rut, telefono):
 * Se debe hacer join con la colección 'usuarios' usando idUsuario
 */
class Profesional
{
    protected Firestore $firestore;
    protected string $collection = 'profesionales';

    public function __construct(Firestore $firestore)
    {
        $this->firestore = $firestore;
    }

    /**
     * Obtener todos los profesionales
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $profesionales = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $profesionales[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $profesionales;
    }

    /**
     * Buscar profesional por ID
     */
    public function find(string $id): ?array
    {
        $document = $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->snapshot();

        if (!$document->exists()) {
            return null;
        }

        return $this->formatDates($document->data(), $document->id());
    }

    /**
     * Buscar profesional por RUT (deprecated - usar Usuario::findByRut)
     * 
     * @deprecated Use Usuario::findByRut() en su lugar
     */
    public function findByRut(string $rut): ?array
    {
        // Buscar en usuarios y luego obtener el profesional vinculado
        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->findByRut($rut);
        
        if (!$usuario || !isset($usuario['idProfesional'])) {
            return null;
        }
        
        return $this->find($usuario['idProfesional']);
    }

    /**
     * Buscar profesional por ID de usuario
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
                return $this->formatDates($document->data(), $document->id());
            }
        }

        return null;
    }

    /**
     * Obtener profesional con datos de usuario
     */
    public function findWithUser(string $id): ?array
    {
        $profesional = $this->find($id);
        
        if (!$profesional || !isset($profesional['idUsuario'])) {
            return $profesional;
        }

        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->find($profesional['idUsuario']);

        if ($usuario) {
            $profesional['usuario'] = [
                'id' => $usuario['id'],
                'displayName' => $usuario['displayName'] ?? '',
                'email' => $usuario['email'] ?? '',
                'rut' => $usuario['rut'] ?? '',
                'telefono' => $usuario['telefono'] ?? '',
                'photoURL' => $usuario['photoURL'] ?? null,
            ];
        }

        return $profesional;
    }

    /**
     * Obtener todos los profesionales con datos de usuario
     */
    public function allWithUsers(): array
    {
        $profesionales = $this->all();
        $usuarioModel = new Usuario();

        return array_map(function($profesional) use ($usuarioModel) {
            if (isset($profesional['idUsuario'])) {
                $usuario = $usuarioModel->find($profesional['idUsuario']);
                if ($usuario) {
                    $profesional['usuario'] = [
                        'id' => $usuario['id'],
                        'displayName' => $usuario['displayName'] ?? '',
                        'email' => $usuario['email'] ?? '',
                        'rut' => $usuario['rut'] ?? '',
                        'telefono' => $usuario['telefono'] ?? '',
                        'photoURL' => $usuario['photoURL'] ?? null,
                    ];
                }
            }
            return $profesional;
        }, $profesionales);
    }

    /**
     * Buscar profesionales por especialidad
     */
    public function findByEspecialidad(string $especialidad): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('especialidad', '=', $especialidad)
            ->documents();

        $profesionales = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $profesionales[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $profesionales;
    }

    /**
     * Crear un nuevo profesional
     * 
     * IMPORTANTE: idUsuario es OBLIGATORIO
     */
    public function create(array $data): string
    {
        if (empty($data['idUsuario'])) {
            throw new \Exception('El campo idUsuario es obligatorio');
        }

        // Validar que el usuario exista
        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->find($data['idUsuario']);
        
        if (!$usuario) {
            throw new \Exception("El usuario con ID {$data['idUsuario']} no existe");
        }

        // Validar que no tenga ya un profesional vinculado
        $existing = $this->findByUsuarioId($data['idUsuario']);
        if ($existing) {
            throw new \Exception("El usuario {$data['idUsuario']} ya tiene un profesional vinculado");
        }

        $data['createdAt'] = new \DateTime();
        $data['updatedAt'] = new \DateTime();

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        // Actualizar usuario con idProfesional
        $usuarioModel->update($data['idUsuario'], [
            'idProfesional' => $docRef->id()
        ]);

        return $docRef->id();
    }

    /**
     * Actualizar un profesional
     */
    public function update(string $id, array $data): bool
    {
        $data['updatedAt'] = new \DateTime();

        // No permitir cambiar idUsuario
        if (isset($data['idUsuario'])) {
            unset($data['idUsuario']);
            logger()->warning("Intento de cambiar idUsuario en profesional {$id} - campo ignorado");
        }

        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->set($data, ['merge' => true]);

        return true;
    }

    /**
     * Eliminar un profesional
     * También elimina la referencia en el usuario
     */
    public function delete(string $id): bool
    {
        $profesional = $this->find($id);
        
        if ($profesional && isset($profesional['idUsuario'])) {
            $usuarioModel = new Usuario();
            try {
                $usuarioModel->update($profesional['idUsuario'], [
                    'idProfesional' => null
                ]);
            } catch (\Exception $e) {
                logger()->warning("No se pudo actualizar usuario al eliminar profesional: " . $e->getMessage());
            }
        }

        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->delete();

        return true;
    }

    /**
     * Buscar profesionales por nombre (deprecated)
     * @deprecated Buscar en la colección 'usuarios' con rol='profesional'
     */
    public function search(string $query): array
    {
        $usuarioModel = new Usuario();
        $allUsuarios = $usuarioModel->getByRole('profesional');
        
        $usuariosFiltrados = array_filter($allUsuarios, function($usuario) use ($query) {
            $queryLower = strtolower($query);
            $nombre = strtolower($usuario['displayName'] ?? '');
            $email = strtolower($usuario['email'] ?? '');
            $rut = strtolower($usuario['rut'] ?? '');
            
            return str_contains($nombre, $queryLower) || 
                   str_contains($email, $queryLower) ||
                   str_contains($rut, $queryLower);
        });

        $profesionales = [];
        foreach ($usuariosFiltrados as $usuario) {
            if (isset($usuario['idProfesional'])) {
                $profesional = $this->find($usuario['idProfesional']);
                if ($profesional) {
                    $profesional['usuario'] = [
                        'displayName' => $usuario['displayName'] ?? '',
                        'email' => $usuario['email'] ?? '',
                        'rut' => $usuario['rut'] ?? '',
                        'telefono' => $usuario['telefono'] ?? '',
                    ];
                    $profesionales[] = $profesional;
                }
            }
        }

        return $profesionales;
    }

    /**
     * Formatear fechas de Firestore a Carbon
     */
    private function formatDates(array $data, string $id): array
    {
        $data['id'] = $id;

        if (isset($data['createdAt'])) {
            $data['createdAt'] = $this->convertTimestamp($data['createdAt']);
        }

        if (isset($data['updatedAt'])) {
            $data['updatedAt'] = $this->convertTimestamp($data['updatedAt']);
        }

        return $data;
    }

    /**
     * Convertir Firestore Timestamp a Carbon
     */
    private function convertTimestamp($timestamp): string
    {
        if ($timestamp instanceof \Google\Cloud\Core\Timestamp) {
            return Carbon::createFromTimestamp($timestamp->get()->getTimestamp())->toIso8601String();
        }
        
        if ($timestamp instanceof \DateTime) {
            return Carbon::instance($timestamp)->toIso8601String();
        }

        return $timestamp;
    }
}
