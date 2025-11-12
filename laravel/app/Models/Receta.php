<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class Receta
{
    protected Firestore $firestore;
    protected string $collection = 'recetas';

    public function __construct(Firestore $firestore)
    {
        $this->firestore = $firestore;
    }

    /**
     * Obtener todas las recetas
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $recetas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $recetas[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $recetas;
    }

    /**
     * Buscar receta por ID
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
     * Buscar recetas por paciente
     */
    public function findByPaciente(string $idPaciente): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idPaciente', '=', $idPaciente)
            ->documents();

        $recetas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $recetas[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $recetas;
    }

    /**
     * Buscar recetas por profesional
     */
    public function findByProfesional(string $idProfesional): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idProfesional', '=', $idProfesional)
            ->documents();

        $recetas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $recetas[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $recetas;
    }

    /**
     * Buscar recetas por consulta
     */
    public function findByConsulta(string $idConsulta): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idConsulta', '=', $idConsulta)
            ->documents();

        $recetas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $recetas[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $recetas;
    }

    /**
     * Crear una nueva receta
     */
    public function create(array $data): string
    {
        $data['createdAt'] = new \DateTime();
        $data['updatedAt'] = new \DateTime();

        // Asegurar que fecha sea DateTime si viene como string
        if (isset($data['fecha']) && is_string($data['fecha'])) {
            $data['fecha'] = new \DateTime($data['fecha']);
        }

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        return $docRef->id();
    }

    /**
     * Actualizar una receta
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
     * Eliminar una receta
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
     * Agregar medicamento a una receta
     */
    public function agregarMedicamento(string $id, array $medicamento): bool
    {
        $receta = $this->find($id);
        if (!$receta) {
            return false;
        }

        $medicamentos = $receta['medicamentos'] ?? [];
        $medicamentos[] = $medicamento;

        return $this->update($id, ['medicamentos' => $medicamentos]);
    }

    /**
     * Formatear fechas de Firestore a Carbon
     */
    private function formatDates(array $data, string $id): array
    {
        $data['id'] = $id;

        if (isset($data['fecha'])) {
            $data['fecha'] = $this->convertTimestamp($data['fecha']);
        }

        if (isset($data['createdAt'])) {
            $data['createdAt'] = $this->convertTimestamp($data['createdAt']);
        }

        if (isset($data['updatedAt'])) {
            $data['updatedAt'] = $this->convertTimestamp($data['updatedAt']);
        }

        // Formatear fechas en medicamentos si existen
        if (isset($data['medicamentos']) && is_array($data['medicamentos'])) {
            foreach ($data['medicamentos'] as &$medicamento) {
                if (isset($medicamento['fechaResultado'])) {
                    $medicamento['fechaResultado'] = $this->convertTimestamp($medicamento['fechaResultado']);
                }
            }
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
