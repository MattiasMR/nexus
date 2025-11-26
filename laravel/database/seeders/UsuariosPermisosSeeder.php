<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Usuario;
use App\Models\PermisoUsuario;

class UsuariosPermisosSeeder extends Seeder
{
    /**
     * Seed de usuarios y permisos por rol
     * 
     * Crea 6 usuarios (2 por cada rol: Admin, Profesional, Paciente)
     * y asigna los permisos correspondientes a cada uno
     */
    public function run(): void
    {
        // ID del hospital
        $idHospital = 'RSAlN3zsmWzeoY3z9GzN';

        echo "\n🚀 Iniciando seed de usuarios y permisos...\n\n";

        // Helper function para crear o recuperar usuario
        $crearORecuperarUsuario = function($data) {
            $usuarioModel = new Usuario();
            $existente = $usuarioModel->findByEmail($data['email']);
            
            if ($existente) {
                echo "   ⚠️  Usuario ya existe: {$existente['displayName']} ({$existente['email']})\n";
                return $existente;
            }
            
            $usuario = Usuario::create($data);
            echo "   ✓ Usuario creado: {$usuario['displayName']} ({$usuario['email']})\n";
            return $usuario;
        };

        // Helper function para crear o recuperar permisos
        $crearORecuperarPermisos = function($idUsuario, $idHospital, $permisos, $nombreUsuario) {
            $permisoModel = new PermisoUsuario();
            $existente = $permisoModel->getByUsuarioAndHospital($idUsuario, $idHospital);
            
            if ($existente) {
                echo "   ⚠️  Permisos ya existen para {$nombreUsuario}\n";
                return $existente;
            }
            
            $permiso = PermisoUsuario::create([
                'idUsuario' => $idUsuario,
                'idHospital' => $idHospital,
                'permisos' => $permisos,
            ]);
            echo "   ✓ Permisos asignados a {$nombreUsuario}\n";
            return $permiso;
        };

        // ============================================
        // 1. USUARIOS ADMIN
        // ============================================
        echo "👤 Creando usuarios Admin...\n";

        $admin1Data = [
            'email' => 'admin1@nexus.cl',
            'displayName' => 'Administrador Principal',
            'rol' => 'admin',
            'activo' => true,
        ];
        $admin1 = $crearORecuperarUsuario($admin1Data);

        $admin2Data = [
            'email' => 'admin2@nexus.cl',
            'displayName' => 'Administrador Secundario',
            'rol' => 'admin',
            'activo' => true,
        ];
        $admin2 = $crearORecuperarUsuario($admin2Data);

        // Permisos para ambos admins
        $permisosAdmin = [
            'gestionar_usuarios',
            'gestionar_profesionales',
            'gestionar_pacientes',
            'gestionar_examenes_catalogo',
            'gestionar_medicamentos_catalogo',
            'configurar_hospital',
            'ver_reportes',
        ];

        $crearORecuperarPermisos($admin1['id'], $idHospital, $permisosAdmin, 'Admin 1');
        $crearORecuperarPermisos($admin2['id'], $idHospital, $permisosAdmin, 'Admin 2');
        echo "\n";

        // ============================================
        // 2. USUARIOS PROFESIONAL
        // ============================================
        echo "👨‍⚕️ Creando usuarios Profesional...\n";

        $profesional1Data = [
            'email' => 'dr.gonzalez@nexus.cl',
            'displayName' => 'Dr. Carlos González',
            'rol' => 'profesional',
            'activo' => true,
        ];
        $profesional1 = $crearORecuperarUsuario($profesional1Data);

        $profesional2Data = [
            'email' => 'dra.martinez@nexus.cl',
            'displayName' => 'Dra. Ana Martínez',
            'rol' => 'profesional',
            'activo' => true,
        ];
        $profesional2 = $crearORecuperarUsuario($profesional2Data);

        // Permisos para ambos profesionales
        $permisosProfesional = [
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

        $crearORecuperarPermisos($profesional1['id'], $idHospital, $permisosProfesional, 'Profesional 1');
        $crearORecuperarPermisos($profesional2['id'], $idHospital, $permisosProfesional, 'Profesional 2');
        echo "\n";

        // ============================================
        // 3. USUARIOS PACIENTE
        // ============================================
        echo "🏥 Creando usuarios Paciente...\n";

        // Crear usuarios pacientes (sin vincular a pacientes existentes aún)
        $paciente1Data = [
            'email' => 'juan.perez@email.com',
            'displayName' => 'Juan Pérez',
            'rut' => '12345678-9',
            'telefono' => '+56912345678',
            'rol' => 'paciente',
            'activo' => true,
        ];
        $pacienteUser1 = $crearORecuperarUsuario($paciente1Data);

        $paciente2Data = [
            'email' => 'maria.lopez@email.com',
            'displayName' => 'María López',
            'rut' => '98765432-1',
            'telefono' => '+56987654321',
            'rol' => 'paciente',
            'activo' => true,
        ];
        $pacienteUser2 = $crearORecuperarUsuario($paciente2Data);

        // Permisos para ambos pacientes
        $permisosPaciente = [
            'ver_mi_ficha',
            'ver_mis_consultas',
            'ver_mis_examenes',
            'ver_mis_recetas',
            'descargar_documentos',
            'comprar_bonos',
        ];

        $crearORecuperarPermisos($pacienteUser1['id'], $idHospital, $permisosPaciente, 'Paciente 1');
        $crearORecuperarPermisos($pacienteUser2['id'], $idHospital, $permisosPaciente, 'Paciente 2');

        echo "\n";

        // ============================================
        // RESUMEN
        // ============================================
        echo "✅ Seed completado exitosamente!\n\n";
        echo "📊 Resumen:\n";
        echo "   • 2 Administradores creados\n";
        echo "   • 2 Profesionales creados\n";
        echo "   • 2 Pacientes creados\n";
        echo "   • Total: 6 usuarios con permisos asignados\n\n";

        echo "🔑 Credenciales de acceso (para pruebas):\n";
        echo "   Admin 1: admin1@nexus.cl\n";
        echo "   Admin 2: admin2@nexus.cl\n";
        echo "   Profesional 1: dr.gonzalez@nexus.cl\n";
        echo "   Profesional 2: dra.martinez@nexus.cl\n";
        echo "   Paciente 1: juan.perez@email.com\n";
        echo "   Paciente 2: maria.lopez@email.com\n\n";

        echo "⚠️  IMPORTANTE:\n";
        echo "   • Configura las contraseñas en Firebase Authentication\n";
        echo "   • Hospital: RSAlN3zsmWzeoY3z9GzN\n";
        echo "   • Todos los usuarios ya están vinculados con su rol correspondiente\n";
        echo "   • Los pacientes están listos para ser vinculados a datos médicos\n\n";
    }
}
