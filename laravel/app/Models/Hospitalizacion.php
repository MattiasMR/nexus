<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class Hospitalizacion
{
    protected Firestore $firestore;
    protected string $collection = 'hospitalizaciones';

    public function __construct(Firestore $firestore)
    {
        $this->firestore = $firestore;
    }

    /**
     * Obtener todas las hospitalizaciones
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $hospitalizaciones = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $hospitalizaciones[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $hospitalizaciones;
    }

    /**
     * Buscar hospitalización por ID
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
     * Buscar hospitalizaciones por paciente
     */
    public function findByPaciente(string $idPaciente): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idPaciente', '=', $idPaciente)
            ->documents();

        $hospitalizaciones = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $hospitalizaciones[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $hospitalizaciones;
    }

    /**
     * Buscar hospitalizaciones activas (sin fecha de alta)
     */
    public function findActivas(): array
    {
        $allHospitalizaciones = $this->all();
        
        return array_filter($allHospitalizaciones, function($hospitalizacion) {
            return empty($hospitalizacion['fechaAlta']);
        });
    }

    /**
     * Buscar hospitalizaciones por profesional
     */
    public function findByProfesional(string $idProfesional): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idProfesional', '=', $idProfesional)
            ->documents();

        $hospitalizaciones = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $hospitalizaciones[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $hospitalizaciones;
    }

    /**
     * Crear una nueva hospitalización
     */
    public function create(array $data): string
    {
        $data['createdAt'] = new \DateTime();
        $data['updatedAt'] = new \DateTime();

        // Convertir fechas si vienen como string
        if (isset($data['fechaIngreso']) && is_string($data['fechaIngreso'])) {
            $data['fechaIngreso'] = new \DateTime($data['fechaIngreso']);
        }

        if (isset($data['fechaAlta']) && is_string($data['fechaAlta'])) {
            $data['fechaAlta'] = new \DateTime($data['fechaAlta']);
        }

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        return $docRef->id();
    }

    /**
     * Actualizar una hospitalización
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
     * Dar de alta a un paciente
     */
    public function darAlta(string $id, string $fechaAlta = null): bool
    {
        $fecha = $fechaAlta ? new \DateTime($fechaAlta) : new \DateTime();
        
        return $this->update($id, ['fechaAlta' => $fecha]);
    }

    /**
     * Agregar intervención
     */
    public function agregarIntervencion(string $id, string $intervencion): bool
    {
        $hospitalizacion = $this->find($id);
        if (!$hospitalizacion) {
            return false;
        }

        $intervenciones = $hospitalizacion['intervencion'] ?? [];
        $intervenciones[] = $intervencion;

        return $this->update($id, ['intervencion' => $intervenciones]);
    }

    /**
     * Eliminar una hospitalización
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

        if (isset($data['fechaIngreso'])) {
            $data['fechaIngreso'] = $this->convertTimestamp($data['fechaIngreso']);
        }

        if (isset($data['fechaAlta'])) {
            $data['fechaAlta'] = $this->convertTimestamp($data['fechaAlta']);
        }

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
