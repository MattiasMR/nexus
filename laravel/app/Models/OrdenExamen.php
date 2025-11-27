<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

class OrdenExamen
{
    protected Firestore $firestore;
    protected string $collection = 'ordenesExamenes';

    public function __construct()
    {
        $this->firestore = app(Firestore::class);
    }

    /**
     * Obtener todas las órdenes de examen
     */
    public function all(): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->documents();

        $ordenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $ordenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $ordenes;
    }

    /**
     * Buscar orden por ID
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
     * Buscar órdenes por paciente
     */
    public function findByPaciente(string $idPaciente): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idPaciente', '=', $idPaciente)
            ->documents();

        $ordenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $ordenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $ordenes;
    }

    /**
     * Buscar órdenes por profesional
     */
    public function findByProfesional(string $idProfesional): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idProfesional', '=', $idProfesional)
            ->documents();

        $ordenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $ordenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $ordenes;
    }

    /**
     * Buscar órdenes por estado
     */
    public function findByEstado(string $estado): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('estado', '=', $estado)
            ->documents();

        $ordenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $ordenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $ordenes;
    }

    /**
     * Buscar órdenes por consulta
     */
    public function findByConsulta(string $idConsulta): array
    {
        $documents = $this->firestore
            ->database()
            ->collection($this->collection)
            ->where('idConsulta', '=', $idConsulta)
            ->documents();

        $ordenes = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $ordenes[] = $this->formatDates($document->data(), $document->id());
            }
        }

        return $ordenes;
    }

    /**
     * Crear una nueva orden de examen
     */
    public function create(array $data): string
    {
        $data['createdAt'] = new \DateTime();
        $data['updatedAt'] = new \DateTime();

        // Convertir fecha si viene como string
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
     * Actualizar una orden
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
     * Cambiar estado de la orden
     */
    public function cambiarEstado(string $id, string $estado): bool
    {
        return $this->update($id, ['estado' => $estado]);
    }

    /**
     * Agregar resultado a un examen
     */
    public function agregarResultado(string $id, int $indexExamen, string $resultado, string $fechaResultado = null): bool
    {
        $orden = $this->find($id);
        if (!$orden || !isset($orden['examenes'][$indexExamen])) {
            return false;
        }

        $examenes = $orden['examenes'];
        $examenes[$indexExamen]['resultado'] = $resultado;
        $examenes[$indexExamen]['fechaResultado'] = $fechaResultado ? new \DateTime($fechaResultado) : new \DateTime();

        return $this->update($id, ['examenes' => $examenes]);
    }

    /**
     * Agregar documento a un examen
     */
    public function agregarDocumento(string $id, int $indexExamen, array $documento): bool
    {
        $orden = $this->find($id);
        if (!$orden || !isset($orden['examenes'][$indexExamen])) {
            return false;
        }

        $examenes = $orden['examenes'];
        $documentos = $examenes[$indexExamen]['documentos'] ?? [];
        
        $documento['fechaSubida'] = new \DateTime();
        $documentos[] = $documento;
        
        $examenes[$indexExamen]['documentos'] = $documentos;

        return $this->update($id, ['examenes' => $examenes]);
    }

    /**
     * Eliminar una orden
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

        if (isset($data['fecha'])) {
            $data['fecha'] = $this->convertTimestamp($data['fecha']);
        }

        if (isset($data['createdAt'])) {
            $data['createdAt'] = $this->convertTimestamp($data['createdAt']);
        }

        if (isset($data['updatedAt'])) {
            $data['updatedAt'] = $this->convertTimestamp($data['updatedAt']);
        }

        // Formatear fechas en exámenes
        if (isset($data['examenes']) && is_array($data['examenes'])) {
            foreach ($data['examenes'] as &$examen) {
                if (isset($examen['fechaResultado'])) {
                    $examen['fechaResultado'] = $this->convertTimestamp($examen['fechaResultado']);
                }
                
                // Formatear fechas en documentos
                if (isset($examen['documentos']) && is_array($examen['documentos'])) {
                    foreach ($examen['documentos'] as &$documento) {
                        if (isset($documento['fechaSubida'])) {
                            $documento['fechaSubida'] = $this->convertTimestamp($documento['fechaSubida']);
                        }
                    }
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
            return Carbon::createFromTimestamp($timestamp->get()->getTimestamp())->toIso8601String();
        }
        
        if ($timestamp instanceof \DateTime) {
            return Carbon::instance($timestamp)->toIso8601String();
        }

        return $timestamp;
    }
}
