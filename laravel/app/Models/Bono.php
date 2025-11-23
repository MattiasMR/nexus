<?php

namespace App\Models;

class Bono
{
    /**
     * Tipos de bonos disponibles con sus precios
     */
    public static function tipos(): array
    {
        return [
            [
                'id' => 'consulta_general',
                'nombre' => 'Consulta Médica General',
                'descripcion' => 'Atención médica general con médico de cabecera',
                'precio' => 25000,
                'duracion_dias' => 90,
            ],
            [
                'id' => 'consulta_especialidad',
                'nombre' => 'Consulta de Especialidad',
                'descripcion' => 'Atención con médico especialista (cardiólogo, traumatólogo, etc.)',
                'precio' => 45000,
                'duracion_dias' => 60,
            ],
            [
                'id' => 'examenes_laboratorio',
                'nombre' => 'Exámenes de Laboratorio',
                'descripcion' => 'Paquete básico de exámenes de laboratorio clínico',
                'precio' => 35000,
                'duracion_dias' => 45,
            ],
            [
                'id' => 'examenes_imagenologia',
                'nombre' => 'Exámenes de Imagenología',
                'descripcion' => 'Radiografías, ecografías u otros estudios por imágenes',
                'precio' => 50000,
                'duracion_dias' => 60,
            ],
            [
                'id' => 'procedimiento_menor',
                'nombre' => 'Procedimiento Menor',
                'descripcion' => 'Procedimientos ambulatorios menores (curaciones, suturas, etc.)',
                'precio' => 30000,
                'duracion_dias' => 30,
            ],
            [
                'id' => 'control_cronico',
                'nombre' => 'Control de Enfermedad Crónica',
                'descripcion' => 'Seguimiento y control de pacientes con enfermedades crónicas',
                'precio' => 20000,
                'duracion_dias' => 120,
            ],
        ];
    }

    /**
     * Obtener un tipo de bono específico por ID
     */
    public static function obtenerPorId(string $id): ?array
    {
        $tipos = self::tipos();
        
        foreach ($tipos as $tipo) {
            if ($tipo['id'] === $id) {
                return $tipo;
            }
        }
        
        return null;
    }

    /**
     * Calcular fecha de vencimiento
     */
    public static function calcularVencimiento(int $dias): string
    {
        return now()->addDays($dias)->format('Y-m-d');
    }

    /**
     * Formatear precio en pesos chilenos
     */
    public static function formatearPrecio(int $precio): string
    {
        return '$' . number_format($precio, 0, ',', '.');
    }
}
