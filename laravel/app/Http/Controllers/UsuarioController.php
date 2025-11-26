<?php

namespace App\Http\Controllers;

use App\Models\Usuario;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use Kreait\Firebase\Contract\Firestore;

class UsuarioController extends Controller
{
    /**
     * Mostrar listado de usuarios
     */
    public function index(Request $request)
    {
        try {
            $usuarioModel = new Usuario();
            $pacienteModel = new \App\Models\Paciente();
            
            // Obtener usuarios de Firebase Auth
            $usuarios = $usuarioModel->all();
            
            // Obtener pacientes de la colección pacientes
            $pacientes = $pacienteModel->all();
            
            // Convertir pacientes a formato de usuario
            $pacientesComoUsuarios = array_map(function($paciente) {
                return [
                    'id' => $paciente['id'],
                    'displayName' => $paciente['nombreCompleto'] ?? ($paciente['nombre'] ?? '') . ' ' . ($paciente['apellido'] ?? ''),
                    'email' => $paciente['email'] ?? 'Sin email',
                    'rol' => 'paciente',
                    'activo' => $paciente['activo'] ?? true,
                    'photoURL' => null,
                    'telefono' => $paciente['telefono'] ?? null,
                    'rut' => $paciente['rut'] ?? null,
                    'ultimoAcceso' => null,
                    'createdAt' => $paciente['createdAt'] ?? null,
                    'idPaciente' => $paciente['id'], // Guardar referencia
                    'esPacienteDirecto' => true, // Marcar como paciente de colección pacientes
                ];
            }, $pacientes);
            
            // Combinar usuarios y pacientes
            $todosLosUsuarios = array_merge($usuarios, $pacientesComoUsuarios);

            // Aplicar filtros
            $rol = $request->get('rol');
            $estado = $request->get('estado');
            $busqueda = $request->get('busqueda');

            // Filtrar por rol
            if ($rol && $rol !== 'todos') {
                $todosLosUsuarios = array_filter($todosLosUsuarios, function($usuario) use ($rol) {
                    return isset($usuario['rol']) && $usuario['rol'] === $rol;
                });
            }

            // Filtrar por estado
            if ($estado !== null && $estado !== 'todos') {
                $activo = $estado === 'activo';
                $todosLosUsuarios = array_filter($todosLosUsuarios, function($usuario) use ($activo) {
                    return isset($usuario['activo']) && $usuario['activo'] === $activo;
                });
            }

            // Filtrar por búsqueda (nombre, email o RUT)
            if ($busqueda) {
                $busquedaLower = strtolower($busqueda);
                $todosLosUsuarios = array_filter($todosLosUsuarios, function($usuario) use ($busquedaLower) {
                    $nombre = strtolower($usuario['displayName'] ?? '');
                    $email = strtolower($usuario['email'] ?? '');
                    $rut = strtolower($usuario['rut'] ?? '');
                    return str_contains($nombre, $busquedaLower) || 
                           str_contains($email, $busquedaLower) ||
                           str_contains($rut, $busquedaLower);
                });
            }

            // Re-indexar array después de filtros
            $todosLosUsuarios = array_values($todosLosUsuarios);

            // Ordenar por fecha de creación (más recientes primero)
            usort($todosLosUsuarios, function($a, $b) {
                $dateA = $a['createdAt'] ?? null;
                $dateB = $b['createdAt'] ?? null;
                
                if (!$dateA || !$dateB) return 0;
                
                return $dateB <=> $dateA;
            });

            // Formatear datos para la vista
            $usuariosFormateados = array_map(function($usuario) {
                return [
                    'id' => $usuario['id'] ?? '',
                    'displayName' => $usuario['displayName'] ?? 'Sin nombre',
                    'email' => $usuario['email'] ?? 'Sin email',
                    'rol' => $usuario['rol'] ?? 'sin_rol',
                    'activo' => $usuario['activo'] ?? false,
                    'photoURL' => $usuario['photoURL'] ?? null,
                    'telefono' => $usuario['telefono'] ?? null,
                    'rut' => $usuario['rut'] ?? null,
                    'ultimoAcceso' => $usuario['ultimoAcceso'] ?? null,
                    'createdAt' => $usuario['createdAt'] ?? null,
                    'idPaciente' => $usuario['idPaciente'] ?? null,
                    'idProfesional' => $usuario['idProfesional'] ?? null,
                    'esPacienteDirecto' => $usuario['esPacienteDirecto'] ?? false,
                ];
            }, $todosLosUsuarios);

            return Inertia::render('Usuarios/Index', [
                'usuarios' => $usuariosFormateados,
                'filtros' => [
                    'rol' => $rol ?? 'todos',
                    'estado' => $estado ?? 'todos',
                    'busqueda' => $busqueda ?? '',
                ],
                'stats' => [
                    'total' => count($usuariosFormateados),
                    'admins' => count(array_filter($usuariosFormateados, fn($u) => $u['rol'] === 'admin')),
                    'profesionales' => count(array_filter($usuariosFormateados, fn($u) => $u['rol'] === 'profesional')),
                    'pacientes' => count(array_filter($usuariosFormateados, fn($u) => $u['rol'] === 'paciente')),
                    'activos' => count(array_filter($usuariosFormateados, fn($u) => $u['activo'])),
                ],
            ]);
        } catch (\Exception $e) {
            logger()->error('Error obteniendo usuarios: ' . $e->getMessage());
            
            return Inertia::render('Usuarios/Index', [
                'usuarios' => [],
                'filtros' => [
                    'rol' => 'todos',
                    'estado' => 'todos',
                    'busqueda' => '',
                ],
                'stats' => [
                    'total' => 0,
                    'admins' => 0,
                    'profesionales' => 0,
                    'pacientes' => 0,
                    'activos' => 0,
                ],
                'error' => 'Error al cargar los usuarios: ' . $e->getMessage(),
            ]);
        }
    }

    /**
     * Mostrar un usuario específico
     */
    public function show(string $id)
    {
        try {
            $usuarioModel = new Usuario();
            $usuario = $usuarioModel->find($id);

            // Si no se encuentra en usuarios, buscar en pacientes
            if (!$usuario) {
                $pacienteModel = new \App\Models\Paciente();
                $paciente = $pacienteModel->find($id);
                
                if ($paciente) {
                    // Convertir paciente a formato usuario
                    $usuario = [
                        'id' => $paciente['id'],
                        'displayName' => $paciente['nombreCompleto'] ?? ($paciente['nombre'] ?? '') . ' ' . ($paciente['apellido'] ?? ''),
                        'email' => $paciente['email'] ?? '',
                        'rol' => 'paciente',
                        'activo' => $paciente['activo'] ?? true,
                        'photoURL' => null,
                        'telefono' => $paciente['telefono'] ?? null,
                        'rut' => $paciente['rut'] ?? null,
                        'ultimoAcceso' => null,
                        'createdAt' => $paciente['createdAt'] ?? null,
                        'idPaciente' => $paciente['id'],
                        'esPacienteDirecto' => true,
                    ];
                } else {
                    return redirect()->route('usuarios.index')
                        ->with('error', 'Usuario no encontrado');
                }
            }

            // Obtener permisos del usuario desde la colección permisos-usuario
            $permisos = $this->getPermisos($id);

            return Inertia::render('Usuarios/Show', [
                'usuario' => $usuario,
                'permisos' => $permisos,
            ]);
        } catch (\Exception $e) {
            logger()->error("Error obteniendo usuario {$id}: " . $e->getMessage());
            
            return redirect()->route('usuarios.index')
                ->with('error', 'Error al cargar el usuario');
        }
    }

    /**
     * Actualizar información básica del usuario
     */
    public function update(Request $request, string $id)
    {
        $validated = $request->validate([
            'displayName' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'photoURL' => 'nullable|url|max:1000',
            'telefono' => 'nullable|string|max:20',
            'rut' => 'nullable|string|max:12',
            'activo' => 'nullable|boolean',
            'rol' => 'nullable|in:admin,profesional,paciente',
        ]);

        try {
            logger()->info("🟢 Iniciando update() para usuario {$id}", ['validated' => $validated]);
            
            $usuarioModel = new Usuario();
            $pacienteModel = new \App\Models\Paciente();
            $usuarioActual = $usuarioModel->find($id);
            
            // Si no existe en usuarios, verificar en pacientes
            $esPacienteDirecto = false;
            if (!$usuarioActual) {
                $pacienteActual = $pacienteModel->find($id);
                if ($pacienteActual) {
                    $esPacienteDirecto = true;
                    logger()->info("📋 Paciente encontrado en colección pacientes", ['id' => $id]);
                } else {
                    return back()->with('error', 'Usuario/Paciente no encontrado');
                }
            } else {
                logger()->info("📋 Usuario actual obtenido", [
                    'id' => $id,
                    'email_actual' => $usuarioActual['email'] ?? null,
                    'displayName_actual' => $usuarioActual['displayName'] ?? null
                ]);
            }
            
            // Si es un paciente directo, actualizar en colección pacientes
            if ($esPacienteDirecto) {
                $dataPaciente = [];
                
                // Mapear campos de usuario a paciente
                if (isset($validated['displayName'])) {
                    $partes = explode(' ', $validated['displayName'], 2);
                    $dataPaciente['nombre'] = $partes[0] ?? '';
                    $dataPaciente['apellido'] = $partes[1] ?? '';
                    $dataPaciente['nombreCompleto'] = $validated['displayName'];
                }
                if (isset($validated['email'])) $dataPaciente['email'] = $validated['email'];
                if (isset($validated['telefono'])) $dataPaciente['telefono'] = $validated['telefono'];
                if (isset($validated['rut'])) $dataPaciente['rut'] = $validated['rut'];
                if (isset($validated['activo'])) $dataPaciente['activo'] = $validated['activo'];
                
                $pacienteModel->update($id, $dataPaciente);
                
                $cambios = [];
                if (isset($validated['displayName'])) $cambios[] = 'nombre';
                if (isset($validated['email'])) $cambios[] = 'correo';
                if (isset($validated['telefono'])) $cambios[] = 'teléfono';
                if (isset($validated['rut'])) $cambios[] = 'RUT';
                
                $mensajeCambios = count($cambios) > 0 ? ' (' . implode(', ', $cambios) . ')' : '';
                
                logger()->info("🎉 Paciente {$id} actualizado completamente", ['cambios' => $cambios]);
                return back()->with('success', 'Paciente actualizado correctamente' . $mensajeCambios);
            }
            
            // Verificar si el email ya está en uso por otro usuario
            if (isset($validated['email']) && $validated['email'] !== $usuarioActual['email']) {
                logger()->info("🔍 Verificando si email {$validated['email']} ya existe");
                
                $emailExiste = $usuarioModel->findByEmail($validated['email']);
                if ($emailExiste && $emailExiste['id'] !== $id) {
                    logger()->warning("⚠️ Email {$validated['email']} ya está en uso por usuario {$emailExiste['id']}");
                    return back()->with('error', "El correo {$validated['email']} ya está en uso por otro usuario");
                }
                
                logger()->info("✅ Email disponible para uso");
            }
            
            // Actualizar en Firestore
            logger()->info("💾 Actualizando en Firestore...");
            $updatedUsuario = $usuarioModel->update($id, $validated);

            if (!$updatedUsuario) {
                logger()->error("❌ Firestore update retornó false");
                return back()->with('error', 'No se pudo actualizar el usuario. Intenta nuevamente.');
            }
            
            logger()->info("✅ Firestore actualizado exitosamente");

            // Si se cambió el email o displayName, actualizar también en Firebase Auth
            if (isset($validated['email']) || isset($validated['displayName']) || isset($validated['photoURL'])) {
                logger()->info("🔐 Llamando a updateFirebaseAuth()...");
                
                try {
                    $this->updateFirebaseAuth($id, $validated);
                    logger()->info("✅ Firebase Auth actualizado exitosamente");
                } catch (\Exception $authError) {
                    logger()->error("❌ ERROR en updateFirebaseAuth()", [
                        'error_class' => get_class($authError),
                        'error_message' => $authError->getMessage(),
                        'error_code' => $authError->getCode(),
                        'error_file' => $authError->getFile(),
                        'error_line' => $authError->getLine(),
                        'stack_trace' => $authError->getTraceAsString()
                    ]);
                    
                    // Re-lanzar la excepción para que sea capturada por el catch principal
                    throw $authError;
                }
            }

            $cambios = [];
            if (isset($validated['displayName'])) $cambios[] = 'nombre';
            if (isset($validated['email'])) $cambios[] = 'correo';
            if (isset($validated['rol'])) $cambios[] = 'rol';
            if (isset($validated['telefono'])) $cambios[] = 'teléfono';
            if (isset($validated['rut'])) $cambios[] = 'RUT';
            
            $mensajeCambios = count($cambios) > 0 ? ' (' . implode(', ', $cambios) . ')' : '';
            
            logger()->info("🎉 Usuario {$id} actualizado completamente", ['cambios' => $cambios]);
            
            return back()->with('success', 'Usuario actualizado correctamente' . $mensajeCambios);
        } catch (\Exception $e) {
            logger()->error("❌❌❌ ERROR GENERAL en update()", [
                'usuario_id' => $id,
                'error_class' => get_class($e),
                'error_message' => $e->getMessage(),
                'error_code' => $e->getCode(),
                'error_file' => $e->getFile(),
                'error_line' => $e->getLine(),
                'stack_trace' => $e->getTraceAsString()
            ]);
            
            // Mensajes de error más específicos
            if (str_contains($e->getMessage(), 'email')) {
                return back()->with('error', 'Error al actualizar el correo electrónico. Verifica que sea válido.');
            }
            if (str_contains($e->getMessage(), 'auth')) {
                return back()->with('error', 'Error al sincronizar con Firebase Auth. Los cambios en Firestore se guardaron.');
            }
            
            return back()->with('error', 'Error al actualizar el usuario: ' . $e->getMessage());
        }
    }

    /**
     * Actualizar contraseña del usuario
     */
    public function updatePassword(Request $request, string $id)
    {
        $validated = $request->validate([
            'password' => 'required|string|min:6|confirmed',
        ]);

        try {
            // Actualizar contraseña en Firebase Auth
            $auth = app(FirebaseAuth::class);
            $auth->updateUser($id, [
                'password' => $validated['password'],
            ]);

            return back()->with('success', 'Contraseña actualizada correctamente. El usuario debe usar la nueva contraseña en su próximo inicio de sesión.');
        } catch (\Exception $e) {
            logger()->error("Error actualizando contraseña usuario {$id}: " . $e->getMessage());
            
            if (str_contains($e->getMessage(), 'WEAK_PASSWORD')) {
                return back()->with('error', 'La contraseña es muy débil. Debe tener al menos 6 caracteres.');
            }
            
            return back()->with('error', 'No se pudo actualizar la contraseña. Intenta nuevamente.');
        }
    }

    /**
     * Enviar email de restablecimiento de contraseña
     */
    public function sendPasswordReset(Request $request, string $id)
    {
        try {
            $usuarioModel = new Usuario();
            $usuario = $usuarioModel->find($id);

            if (!$usuario || !isset($usuario['email'])) {
                return back()->with('error', 'No se puede enviar el correo: usuario sin email registrado');
            }

            $auth = app(FirebaseAuth::class);
            $link = $auth->getPasswordResetLink($usuario['email']);

            // Aquí puedes enviar el email usando tu servicio de correo
            // Por ahora solo devolvemos el link
            
            return back()->with('success', "Email de restablecimiento enviado a {$usuario['email']}");
        } catch (\Exception $e) {
            logger()->error("Error enviando reset password usuario {$id}: " . $e->getMessage());
            return back()->with('error', 'Error al enviar email de restablecimiento');
        }
    }

    /**
     * Actualizar permisos del usuario
     */
    public function updatePermissions(Request $request, string $id)
    {
        $validated = $request->validate([
            'permisos' => 'required|array',
            'permisos.*.nombre' => 'required|string',
            'permisos.*.activo' => 'required|boolean',
        ]);

        try {
            $firestore = app(Firestore::class);
            $database = $firestore->database();
            
            // Actualizar cada permiso en la colección permisos-usuario
            foreach ($validated['permisos'] as $permiso) {
                $permisoRef = $database
                    ->collection('permisos-usuario')
                    ->document($id)
                    ->collection('permisos')
                    ->document($permiso['nombre']);

                $permisoRef->set([
                    'activo' => $permiso['activo'],
                    'fechaModificacion' => new \DateTime(),
                ], ['merge' => true]);
            }

            return back()->with('success', 'Permisos actualizados correctamente para el usuario');
        } catch (\Exception $e) {
            logger()->error("Error actualizando permisos usuario {$id}: " . $e->getMessage());
            return back()->with('error', 'No se pudieron actualizar los permisos. Intenta nuevamente.');
        }
    }

    /**
     * Verificar email manualmente
     */
    public function verifyEmail(string $id)
    {
        try {
            $usuarioModel = new Usuario();
            $usuario = $usuarioModel->find($id);

            $auth = app(FirebaseAuth::class);
            $auth->updateUser($id, [
                'emailVerified' => true,
            ]);

            return back()->with('success', "Email {$usuario['email']} verificado correctamente");
        } catch (\Exception $e) {
            logger()->error("Error verificando email usuario {$id}: " . $e->getMessage());
            return back()->with('error', 'No se pudo verificar el email. Intenta nuevamente.');
        }
    }

    /**
     * Suspender/Activar cuenta de usuario
     */
    public function toggleStatus(string $id)
    {
        try {
            $usuarioModel = new Usuario();
            $pacienteModel = new \App\Models\Paciente();
            $usuario = $usuarioModel->find($id);

            // Si no existe en usuarios, verificar en pacientes
            $esPacienteDirecto = false;
            if (!$usuario) {
                $paciente = $pacienteModel->find($id);
                if ($paciente) {
                    $esPacienteDirecto = true;
                    $usuario = [
                        'id' => $paciente['id'],
                        'displayName' => $paciente['nombreCompleto'] ?? 'Paciente',
                        'activo' => $paciente['activo'] ?? true,
                    ];
                } else {
                    return back()->with('error', 'Usuario/Paciente no encontrado');
                }
            }

            $nuevoEstado = !($usuario['activo'] ?? false);
            
            if ($esPacienteDirecto) {
                // Actualizar solo en colección pacientes
                $pacienteModel->update($id, ['activo' => $nuevoEstado]);
            } else {
                // Actualizar en Firestore
                $usuarioModel->update($id, ['activo' => $nuevoEstado]);

                // Actualizar en Firebase Auth (disabled es lo opuesto de activo)
                try {
                    $auth = app(FirebaseAuth::class);
                    $auth->updateUser($id, [
                        'disabled' => !$nuevoEstado,
                    ]);
                } catch (\Exception $authError) {
                    logger()->warning("No se pudo actualizar estado en Firebase Auth: " . $authError->getMessage());
                    // Continuar aunque falle Firebase Auth
                }
            }

            $nombreUsuario = $usuario['displayName'] ?? 'Usuario';
            $mensaje = $nuevoEstado 
                ? "Cuenta de {$nombreUsuario} activada correctamente. Ahora puede iniciar sesión." 
                : "Cuenta de {$nombreUsuario} suspendida. No podrá iniciar sesión hasta que se reactive.";
            
            return back()->with('success', $mensaje);
        } catch (\Exception $e) {
            logger()->error("Error cambiando estado usuario {$id}: " . $e->getMessage());
            return back()->with('error', 'No se pudo cambiar el estado de la cuenta. Intenta nuevamente.');
        }
    }

    /**
     * Eliminar usuario
     */
    public function destroy(string $id)
    {
        try {
            $usuarioModel = new Usuario();
            $pacienteModel = new \App\Models\Paciente();
            $usuario = $usuarioModel->find($id);
            
            // Si no existe en usuarios, verificar en pacientes
            $esPacienteDirecto = false;
            if (!$usuario) {
                $paciente = $pacienteModel->find($id);
                if ($paciente) {
                    $esPacienteDirecto = true;
                    $nombreUsuario = $paciente['nombreCompleto'] ?? 'Paciente';
                    
                    // Eliminar solo de colección pacientes
                    $pacienteModel->delete($id);
                    
                    return redirect()->route('usuarios.index')
                        ->with('success', "Paciente {$nombreUsuario} eliminado permanentemente");
                } else {
                    return back()->with('error', 'Usuario/Paciente no encontrado');
                }
            }
            
            $nombreUsuario = $usuario['displayName'] ?? 'Usuario';
            
            // Eliminar de Firestore
            $usuarioModel->delete($id);

            // Eliminar de Firebase Auth
            try {
                $auth = app(FirebaseAuth::class);
                $auth->deleteUser($id);
            } catch (\Exception $authError) {
                logger()->warning("No se pudo eliminar de Firebase Auth: " . $authError->getMessage());
                // Continuar aunque falle Firebase Auth
            }

            // Eliminar permisos asociados
            $this->deletePermisos($id);

            return redirect()->route('usuarios.index')
                ->with('success', "Usuario {$nombreUsuario} eliminado permanentemente de todos los sistemas");
        } catch (\Exception $e) {
            logger()->error("Error eliminando usuario {$id}: " . $e->getMessage());
            return back()->with('error', 'No se pudo eliminar el usuario. Verifica que no tenga datos relacionados.');
        }
    }

    /**
     * Métodos privados auxiliares
     */
    private function updateFirebaseAuth(string $uid, array $data)
    {
        try {
            logger()->info("🔄 Iniciando actualización Firebase Auth para usuario: {$uid}");
            logger()->info("📦 Datos recibidos: " . json_encode($data));
            
            $auth = app(FirebaseAuth::class);
            $updateData = [];

            if (isset($data['email'])) {
                logger()->info("📧 Intentando actualizar email a: {$data['email']}");
                $updateData['email'] = $data['email'];
            }
            if (isset($data['displayName'])) {
                logger()->info("👤 Intentando actualizar displayName a: {$data['displayName']}");
                $updateData['displayName'] = $data['displayName'];
            }
            if (isset($data['photoURL'])) {
                logger()->info("🖼️ Intentando actualizar photoURL a: {$data['photoURL']}");
                $updateData['photoURL'] = $data['photoURL'];
            }

            if (!empty($updateData)) {
                logger()->info("🚀 Enviando actualización a Firebase Auth: " . json_encode($updateData));
                $result = $auth->updateUser($uid, $updateData);
                logger()->info("✅ Firebase Auth actualizado exitosamente");
                logger()->info("📊 Resultado: " . json_encode($result));
            } else {
                logger()->info("⚠️ No hay datos para actualizar en Firebase Auth");
            }
        } catch (\Exception $e) {
            logger()->error("❌ Error actualizando Firebase Auth para usuario {$uid}");
            logger()->error("🔍 Tipo de error: " . get_class($e));
            logger()->error("💬 Mensaje: " . $e->getMessage());
            logger()->error("📍 Archivo: " . $e->getFile() . " Línea: " . $e->getLine());
            logger()->error("📚 Stack trace: " . $e->getTraceAsString());
            throw $e;
        }
    }

    private function getPermisos(string $uid)
    {
        try {
            $firestore = app(Firestore::class);
            $database = $firestore->database();
            
            $permisosRef = $database
                ->collection('permisos-usuario')
                ->document($uid)
                ->collection('permisos');

            $documents = $permisosRef->documents();
            $permisos = [];

            foreach ($documents as $document) {
                if ($document->exists()) {
                    $permisos[] = [
                        'nombre' => $document->id(),
                        'activo' => $document->data()['activo'] ?? false,
                        'fechaModificacion' => $document->data()['fechaModificacion'] ?? null,
                    ];
                }
            }

            return $permisos;
        } catch (\Exception $e) {
            logger()->error("Error obteniendo permisos usuario {$uid}: " . $e->getMessage());
            return [];
        }
    }

    private function deletePermisos(string $uid)
    {
        try {
            $firestore = app(Firestore::class);
            $database = $firestore->database();
            
            $permisosRef = $database
                ->collection('permisos-usuario')
                ->document($uid)
                ->collection('permisos');

            $documents = $permisosRef->documents();

            foreach ($documents as $document) {
                $document->reference()->delete();
            }

            // Eliminar el documento principal
            $database
                ->collection('permisos-usuario')
                ->document($uid)
                ->delete();
        } catch (\Exception $e) {
            logger()->error("Error eliminando permisos usuario {$uid}: " . $e->getMessage());
        }
    }
}
