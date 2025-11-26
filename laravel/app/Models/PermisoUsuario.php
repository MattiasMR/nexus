<?php

namespace App\Models;

use Kreait\Firebase\Contract\Firestore;

class PermisoUsuario
{
    protected Firestore $firestore;
    protected string $collection = 'permisos-usuario';

    // Constantes de permisos por rol
    const PERMISOS_ADMIN = [
        'gestionar_usuarios',
        'gestionar_profesionales',
        'gestionar_pacientes',
        'gestionar_examenes_catalogo',
        'gestionar_medicamentos_catalogo',
        'configurar_hospital',
        'ver_reportes',
    ];

    const PERMISOS_PROFESIONAL = [
        'ver_pacientes',
        'crear_consultas',
        'editar_consultas',
        'ver_fichas_medicas',
        'editar_fichas_medicas',
        'crear_recetas',
        'editar_recetas',
        'solicitar_examenes',
        'ver_examenes',
        'hospitalizar_paciente',
        'editar_hospitalizacion',
    ];

    const PERMISOS_PACIENTE = [
        'ver_mi_ficha',
        'ver_mis_consultas',
        'ver_mis_examenes',
        'ver_mis_recetas',
        'descargar_documentos',
        'comprar_bonos',
    ];

    public function __construct()
    {
        $this->firestore = app(Firestore::class);
    }

    /**
     * Obtener todos los permisos
     */
    public function all(): array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->documents();

            $permisos = [];
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    $permisos[] = $data;
                }
            }

            return $permisos;
        } catch (\Exception $e) {
            logger()->error('Error obteniendo permisos: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Buscar permisos por ID
     */
    public function find(string $id): ?array
    {
        try {
            $document = $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->snapshot();

            if ($document->exists()) {
                $data = $document->data();
                $data['id'] = $document->id();
                return $data;
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error buscando permisos {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Obtener permisos por usuario y hospital
     */
    public function getByUsuarioAndHospital(string $idUsuario, string $idHospital): ?array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('idUsuario', '=', $idUsuario)
                ->where('idHospital', '=', $idHospital)
                ->limit(1)
                ->documents();

            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    return $data;
                }
            }

            return null;
        } catch (\Exception $e) {
            logger()->error("Error obteniendo permisos usuario {$idUsuario} hospital {$idHospital}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Obtener todos los permisos de un usuario
     */
    public function getByUsuario(string $idUsuario): array
    {
        try {
            $documents = $this->firestore
                ->database()
                ->collection($this->collection)
                ->where('idUsuario', '=', $idUsuario)
                ->documents();

            $permisos = [];
            foreach ($documents as $document) {
                if ($document->exists()) {
                    $data = $document->data();
                    $data['id'] = $document->id();
                    $permisos[] = $data;
                }
            }

            return $permisos;
        } catch (\Exception $e) {
            logger()->error("Error obteniendo permisos de usuario {$idUsuario}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Crear permisos para un usuario
     */
    public static function create(array $data): array
    {
        $instance = new self();
        
        try {
            // Validar campos requeridos
            if (!isset($data['idUsuario']) || !isset($data['idHospital'])) {
                throw new \Exception('Se requieren idUsuario e idHospital');
            }

            // Verificar si ya existen permisos para este usuario-hospital
            $existing = $instance->getByUsuarioAndHospital($data['idUsuario'], $data['idHospital']);
            if ($existing) {
                throw new \Exception('Ya existen permisos para este usuario en este hospital');
            }

            // Agregar timestamps
            $now = new \DateTime();
            $data['createdAt'] = $now;
            $data['updatedAt'] = $now;
            $data['fechaInicio'] = $data['fechaInicio'] ?? $now;

            // Asegurar que permisos sea un array
            if (!isset($data['permisos'])) {
                $data['permisos'] = [];
            }

            // Crear el documento
            $docRef = $instance->firestore
                ->database()
                ->collection($instance->collection)
                ->add($data);

            // Retornar los permisos creados con su ID
            $data['id'] = $docRef->id();
            return $data;

        } catch (\Exception $e) {
            logger()->error('Error creando permisos: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Actualizar permisos
     */
    public function update(string $id, array $data): array
    {
        try {
            $data['updatedAt'] = new \DateTime();

            $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->set($data, ['merge' => true]);

            return $this->find($id);
        } catch (\Exception $e) {
            logger()->error("Error actualizando permisos {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Eliminar permisos
     */
    public function delete(string $id): bool
    {
        try {
            $this->firestore
                ->database()
                ->collection($this->collection)
                ->document($id)
                ->delete();

            return true;
        } catch (\Exception $e) {
            logger()->error("Error eliminando permisos {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Verificar si un usuario tiene un permiso específico
     */
    public function hasPermiso(string $idUsuario, string $idHospital, string $permiso): bool
    {
        try {
            $permisos = $this->getByUsuarioAndHospital($idUsuario, $idHospital);
            
            if (!$permisos || !isset($permisos['permisos'])) {
                return false;
            }

            return in_array($permiso, $permisos['permisos']);
        } catch (\Exception $e) {
            logger()->error("Error verificando permiso {$permiso} para usuario {$idUsuario}: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Agregar permisos a un usuario (sin sobrescribir los existentes)
     */
    public function addPermisos(string $id, array $nuevosPermisos): array
    {
        try {
            $permisos = $this->find($id);
            
            if (!$permisos) {
                throw new \Exception('Permisos no encontrados');
            }

            $permisosActuales = $permisos['permisos'] ?? [];
            $permisosMerged = array_unique(array_merge($permisosActuales, $nuevosPermisos));

            return $this->update($id, ['permisos' => $permisosMerged]);
        } catch (\Exception $e) {
            logger()->error("Error agregando permisos a {$id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Remover permisos específicos de un usuario
     */
    public function removePermisos(string $id, array $permisosARemover): array
    {
        try {
            $permisos = $this->find($id);
            
            if (!$permisos) {
                throw new \Exception('Permisos no encontrados');
            }

            $permisosActuales = $permisos['permisos'] ?? [];
            $permisosFiltrados = array_diff($permisosActuales, $permisosARemover);

            return $this->update($id, ['permisos' => array_values($permisosFiltrados)]);
        } catch (\Exception $e) {
            logger()->error("Error removiendo permisos de {$id}: " . $e->getMessage());
            throw $e;
        }
    }
}
