<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class Diagnostico
{
    protected Firestore $firestore;
    protected string $collection = 'diagnosticos';

    public function __construct()
    {
        $this->firestore = app(Firestore::class);
    }

    /**
     * Obtener todos los diagnósticos
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $diagnosticos = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $diagnosticos[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $diagnosticos;
    }

    /**
     * Buscar diagnóstico por ID
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
     * Buscar diagnósticos por consulta
     */
    public function findByConsulta(string $idConsulta): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idConsulta', '=', $idConsulta)
            ->documents();

        $diagnosticos = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $diagnosticos[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $diagnosticos;
    }

    /**
     * Buscar diagnósticos por hospitalización
     */
    public function findByHospitalizacion(string $idHospitalizacion): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idHospitalizacion', '=', $idHospitalizacion)
            ->documents();

        $diagnosticos = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $diagnosticos[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $diagnosticos;
    }

    /**
     * Buscar diagnósticos por código CIE-10
     */
    public function findByCodigo(string $codigo): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('codigo', '=', $codigo)
            ->documents();

        $diagnosticos = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $diagnosticos[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $diagnosticos;
    }

    /**
     * Crear un nuevo diagnóstico
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
     * Actualizar un diagnóstico
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
     * Eliminar un diagnóstico
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
