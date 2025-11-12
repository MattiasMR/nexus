<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

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
     * Buscar profesional por RUT
     */
    public function findByRut(string $rut): ?array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('rut', '=', $rut)
            ->documents();

        foreach ($documents as $document) {
            if ($document->exists()) {
                return $this->formatDates($document->data(), $document->id());
            }
        }

        return null;
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
     */
    public function create(array $data): string
    {
        $data['createdAt'] = new \DateTime();
        $data['updatedAt'] = new \DateTime();

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        return $docRef->id();
    }

    /**
     * Actualizar un profesional
     */
    public function update(string $id, array $data): bool
    {
        $data['updatedAt'] = new \DateTime();

        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->set($data, ['merge' => true]);

        return true;
    }

    /**
     * Eliminar un profesional
     */
    public function delete(string $id): bool
    {
        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->delete();

        return true;
    }

    /**
     * Buscar profesionales por nombre
     */
    public function search(string $query): array
    {
        $allProfesionales = $this->all();
        
        return array_filter($allProfesionales, function($profesional) use ($query) {
            $matchNombre = stripos($profesional['nombre'] ?? '', $query) !== false;
            $matchApellido = stripos($profesional['apellido'] ?? '', $query) !== false;
            $matchRut = stripos($profesional['rut'] ?? '', $query) !== false;
            return $matchNombre || $matchApellido || $matchRut;
        });
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
            return Carbon::createFromTimestamp($timestamp->get()->getSeconds())->toIso8601String();
        }
        
        if ($timestamp instanceof \DateTime) {
            return Carbon::instance($timestamp)->toIso8601String();
        }

        return $timestamp;
    }
}
