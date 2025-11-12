<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class Examen
{
    protected Firestore $firestore;
    protected string $collection = 'examenes';

    public function __construct(Firestore $firestore)
    {
        $this->firestore = $firestore;
    }

    /**
     * Obtener todos los exámenes
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $examenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $examenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $examenes;
    }

    /**
     * Buscar examen por ID
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
     * Buscar exámenes por tipo
     */
    public function findByTipo(string $tipo): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('tipo', '=', $tipo)
            ->documents();

        $examenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $examenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $examenes;
    }

    /**
     * Crear un nuevo examen
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
     * Actualizar un examen
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
     * Eliminar un examen
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
     * Buscar exámenes por nombre
     */
    public function search(string $nombre): array
    {
        // Firestore no soporta búsqueda LIKE, obtenemos todos y filtramos
        $allExamenes = $this->all();
        
        return array_filter($allExamenes, function($examen) use ($nombre) {
            return stripos($examen['nombre'], $nombre) !== false;
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
