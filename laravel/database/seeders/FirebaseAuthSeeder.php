<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Kreait\Firebase\Contract\Auth;
use App\Models\Usuario;
use App\Models\PermisoUsuario;

class FirebaseAuthSeeder extends Seeder
{
    /**
     * Seed usuarios en Firebase Authentication y sincronizar con Firestore
     * 
     * Este seeder crea usuarios en Firebase Authentication con sus contraseñas
     * y luego sincroniza los datos con la colección 'usuarios' en Firestore
     */
    public function run(): void
    {
        $auth = app(Auth::class);
        $idHospital = 'RSAlN3zsmWzeoY3z9GzN';

        echo "\n🔐 Iniciando seed de Firebase Authentication...\n\n";

        // Definir usuarios con sus contraseñas
        $usuarios = [
            // Administradores
            [
                'email' => 'admin1@nexus.cl',
                'password' => 'Admin123!',
                'displayName' => 'Administrador Principal',
                'rol' => 'admin',
                'permisos' => PermisoUsuario::PERMISOS_ADMIN,
            ],
            [
                'email' => 'admin2@nexus.cl',
                'password' => 'Admin123!',
                'displayName' => 'Administrador Secundario',
                'rol' => 'admin',
                'permisos' => PermisoUsuario::PERMISOS_ADMIN,
            ],
            
            // Profesionales
            [
                'email' => 'dr.gonzalez@nexus.cl',
                'password' => 'Prof123!',
                'displayName' => 'Dr. Carlos González',
                'rol' => 'profesional',
                'permisos' => PermisoUsuario::PERMISOS_PROFESIONAL,
            ],
            [
                'email' => 'dra.martinez@nexus.cl',
                'password' => 'Prof123!',
                'displayName' => 'Dra. Ana Martínez',
                'rol' => 'profesional',
                'permisos' => PermisoUsuario::PERMISOS_PROFESIONAL,
            ],
            
            // Pacientes
            [
                'email' => 'juan.perez@email.com',
                'password' => 'Pac123!',
                'displayName' => 'Juan Pérez',
                'rol' => 'paciente',
                'idPaciente' => 'Fh2byylkEBfJCxd2vD1P',
                'permisos' => PermisoUsuario::PERMISOS_PACIENTE,
            ],
            [
                'email' => 'maria.lopez@email.com',
                'password' => 'Pac123!',
                'displayName' => 'María López',
                'rol' => 'paciente',
                'idPaciente' => 'SUso7Nyhb18whZ21Z2Ux',
                'permisos' => PermisoUsuario::PERMISOS_PACIENTE,
            ],
        ];

        $creados = 0;
        $existentes = 0;
        $errores = 0;

        foreach ($usuarios as $userData) {
            try {
                $email = $userData['email'];
                $password = $userData['password'];
                $displayName = $userData['displayName'];
                
                // Intentar obtener usuario existente
                try {
                    $firebaseUser = $auth->getUserByEmail($email);
                    echo "   ⚠️  Usuario ya existe en Firebase Auth: {$displayName} ({$email})\n";
                    $uid = $firebaseUser->uid;
                    $existentes++;
                } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
                    // Crear usuario en Firebase Authentication
                    $userProperties = [
                        'email' => $email,
                        'emailVerified' => true,
                        'password' => $password,
                        'displayName' => $displayName,
                        'disabled' => false,
                    ];
                    
                    $createdUser = $auth->createUser($userProperties);
                    $uid = $createdUser->uid;
                    echo "   ✓ Usuario creado en Firebase Auth: {$displayName} ({$email})\n";
                    $creados++;
                }

                // Verificar si ya existe en Firestore
                $usuarioModel = new Usuario();
                $existeFirestore = $usuarioModel->findByFirebaseUid($uid);

                if ($existeFirestore) {
                    echo "   ⚠️  Usuario ya existe en Firestore: {$displayName}\n";
                } else {
                    // Crear documento en Firestore usando el UID como ID
                    $firestoreData = [
                        'email' => $email,
                        'displayName' => $displayName,
                        'rol' => $userData['rol'],
                        'activo' => true,
                    ];

                    if (isset($userData['idPaciente'])) {
                        $firestoreData['idPaciente'] = $userData['idPaciente'];
                    }

                    $now = new \DateTime();
                    $firestoreData['createdAt'] = $now;
                    $firestoreData['updatedAt'] = $now;
                    $firestoreData['ultimoAcceso'] = $now;

                    // Guardar en Firestore con el UID como ID del documento
                    $firestore = app(\Kreait\Firebase\Contract\Firestore::class);
                    $firestore->database()
                        ->collection('usuarios')
                        ->document($uid)
                        ->set($firestoreData);

                    echo "   ✓ Usuario sincronizado con Firestore: {$displayName}\n";
                }

                // Crear o verificar permisos
                $permisoModel = new PermisoUsuario();
                $permisoExistente = $permisoModel->getByUsuarioAndHospital($uid, $idHospital);

                if ($permisoExistente) {
                    echo "   ⚠️  Permisos ya existen para {$displayName}\n";
                } else {
                    PermisoUsuario::create([
                        'idUsuario' => $uid,
                        'idHospital' => $idHospital,
                        'permisos' => $userData['permisos'],
                    ]);
                    echo "   ✓ Permisos asignados a {$displayName}\n";
                }

                echo "\n";

            } catch (\Exception $e) {
                echo "   ❌ Error procesando {$userData['email']}: " . $e->getMessage() . "\n\n";
                $errores++;
            }
        }

        // Resumen final
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "✅ Seed de Firebase Authentication completado\n\n";
        echo "📊 Estadísticas:\n";
        echo "   • Usuarios creados en Firebase Auth: {$creados}\n";
        echo "   • Usuarios ya existentes: {$existentes}\n";
        echo "   • Errores: {$errores}\n";
        echo "   • Total procesados: " . count($usuarios) . "\n\n";

        if ($creados > 0 || $existentes > 0) {
            echo "🔑 Credenciales de acceso:\n\n";
            
            echo "   ADMINISTRADORES (Laravel Web):\n";
            echo "   ├─ admin1@nexus.cl / Admin123!\n";
            echo "   └─ admin2@nexus.cl / Admin123!\n\n";
            
            echo "   PROFESIONALES (Ionic App):\n";
            echo "   ├─ dr.gonzalez@nexus.cl / Prof123!\n";
            echo "   └─ dra.martinez@nexus.cl / Prof123!\n\n";
            
            echo "   PACIENTES (Flutter App):\n";
            echo "   ├─ juan.perez@email.com / Pac123!\n";
            echo "   └─ maria.lopez@email.com / Pac123!\n\n";
        }

        echo "⚠️  IMPORTANTE:\n";
        echo "   • Las contraseñas son temporales\n";
        echo "   • Se recomienda cambiarlas después del primer login\n";
        echo "   • Los UIDs de Firebase se usan como IDs en Firestore\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    }
}
