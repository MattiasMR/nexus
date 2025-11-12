<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class Consulta
{
    protected Firestore $firestore;
    protected string $collection = 'consultas';

    public function __construct()
    {
        $this->firestore = app(Firestore::class);
    }

    /**
     * Obtener todas las consultas
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $consultas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                $consultas[] = $this->formatDates($data);
            }
        }

        return $consultas;
    }

    /**
     * Obtener todas las consultas de un paciente
     */
    public function findByPaciente(string $idPaciente): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idPaciente', '=', $idPaciente)
            ->orderBy('fecha', 'DESC')
            ->documents();

        $consultas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                $consultas[] = $this->formatDates($data);
            }
        }

        return $consultas;
    }

    /**
     * Obtener todas las consultas de una ficha médica
     */
    public function findByFichaMedica(string $idFichaMedica): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idFichaMedica', '=', $idFichaMedica)
            ->orderBy('fecha', 'DESC')
            ->documents();

        $consultas = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                $consultas[] = $this->formatDates($data);
            }
        }

        return $consultas;
    }

    /**
     * Buscar consulta por ID
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
     * Crear una nueva consulta
     */
    public function create(array $data): string
    {
        $data['createdAt'] = now()->toDateTime();
        $data['updatedAt'] = now()->toDateTime();
        
        if (!isset($data['fecha'])) {
            $data['fecha'] = now()->toDateTime();
        }

        $docRef = $this->firestore
            ->database()
            ->collection($this->collection)
            ->add($data);

        // Incrementar contador en ficha médica
        if (isset($data['idFichaMedica'])) {
            $fichaMedica = new FichaMedica();
            $fichaMedica->incrementarConsultas($data['idFichaMedica']);
        }

        return $docRef->id();
    }

    /**
     * Actualizar consulta
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
     * Agregar nota a consulta
     */
    public function agregarNota(string $id, string $texto, string $autor): bool
    {
        $consulta = $this->find($id);
        
        $notas = $consulta['notas'] ?? [];
        $notas[] = [
            'texto' => $texto,
            'autor' => $autor,
            'fecha' => now()->toDateTime()
        ];

        return $this->update($id, ['notas' => $notas]);
    }

    /**
     * Eliminar consulta
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
     * Formatear fechas
     */
    protected function formatDates(array $data): array
    {
        $dateFields = ['fecha', 'createdAt', 'updatedAt'];
        
        foreach ($dateFields as $field) {
            if (isset($data[$field]) && is_object($data[$field])) {
                $data[$field] = Carbon::parse($data[$field]);
            }
        }

        // Formatear fechas en notas
        if (isset($data['notas']) && is_array($data['notas'])) {
            foreach ($data['notas'] as &$nota) {
                if (isset($nota['fecha']) && is_object($nota['fecha'])) {
                    $nota['fecha'] = Carbon::parse($nota['fecha']);
                }
            }
        }

        return $data;
    }
}
