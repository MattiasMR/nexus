<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class FichaMedica
{
    protected Firestore $firestore;
    protected string $collection = 'fichasMedicas';

    public function __construct()
    {
        $this->firestore = app(Firestore::class);
    }

    /**
     * Obtener ficha médica por paciente
     */
    public function findByPaciente(string $idPaciente): ?array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idPaciente', '=', $idPaciente)
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
     * Buscar ficha médica por ID
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
     * Crear una nueva ficha médica
     */
    public function create(array $data): string
    {
        $data['createdAt'] = now()->toDateTime();
        $data['updatedAt'] = now()->toDateTime();
        $data['totalConsultas'] = 0;

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        return $docRef->id();
    }

    /**
     * Actualizar ficha médica
     */
    public function update(string $id, array $data): bool
    {
        $data['updatedAt'] = now()->toDateTime();

        $this->firestore
            ->database()
            ->collection($this->collection)
            ->document($id)
            ->update($data);

        return true;
    }

    /**
     * Incrementar contador de consultas
     */
    public function incrementarConsultas(string $id): bool
    {
        $ficha = $this->find($id);
        $totalConsultas = ($ficha['totalConsultas'] ?? 0) + 1;

        $this->update($id, [
            'totalConsultas' => $totalConsultas,
            'ultimaConsulta' => now()->toDateTime()
        ]);

        return true;
    }

    /**
     * Formatear fechas
     */
    protected function formatDates(array $data): array
    {
        $dateFields = ['fechaMedica', 'ultimaConsulta', 'createdAt', 'updatedAt'];
        
        foreach ($dateFields as $field) {
            if (isset($data[$field]) && is_object($data[$field])) {
                $data[$field] = Carbon::parse($data[$field]);
            }
        }

        return $data;
    }
}
