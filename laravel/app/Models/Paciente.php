<?php

namespace App\Models;

use Carbon\Carbon;
use Kreait\Firebase\Contract\Firestore;

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
     * Buscar paciente por RUT
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
                $data = $document->data();
                $data['id'] = $document->id();
                return $this->formatDates($data);
            }
        }

        return null;
    }

    /**
     * Crear un nuevo paciente
     */
    public function create(array $data): string
    {
        $data['createdAt'] = now()->toDateTime();
        $data['updatedAt'] = now()->toDateTime();
        $data['nombreCompleto'] = ($data['nombre'] ?? '') . ' ' . ($data['apellido'] ?? '');

        $docRef = $this->collection()->add($data);

        return $docRef->id();
    }

    /**
     * Actualizar paciente
     */
    public function update(string $id, array $data): bool
    {
        $data['updatedAt'] = now()->toDateTime();
        
        if (isset($data['nombre']) || isset($data['apellido'])) {
            $current = $this->find($id);
            $nombre = $data['nombre'] ?? $current['nombre'] ?? '';
            $apellido = $data['apellido'] ?? $current['apellido'] ?? '';
            $data['nombreCompleto'] = $nombre . ' ' . $apellido;
        }

        $this->collection()
            ->document($id)
            ->update($data);

        return true;
    }

    /**
     * Eliminar paciente
     */
    public function delete(string $id): bool
    {
        $this->collection()
            ->document($id)
            ->delete();

        return true;
    }

    /**
     * Buscar pacientes por nombre
     */
    public function search(string $query): array
    {
        // Firestore no soporta búsqueda por texto completo
        // Necesitarías usar Algolia o implementar una solución custom
        // Por ahora, obtenemos todos y filtramos en PHP
        $allPacientes = $this->all();
        
        return array_filter($allPacientes, function($paciente) use ($query) {
            $nombreCompleto = strtolower($paciente['nombreCompleto'] ?? '');
            $rut = strtolower($paciente['rut'] ?? '');
            $queryLower = strtolower($query);
            
            return str_contains($nombreCompleto, $queryLower) || 
                   str_contains($rut, $queryLower);
        });
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
