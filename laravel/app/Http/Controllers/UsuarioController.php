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
            
            // Obtener todos los usuarios (ya incluyen pacientes y profesionales vinculados)
            $usuarios = $usuarioModel->all();

            // Aplicar filtros
            $rol = $request->get('rol');
            $estado = $request->get('estado');
            $busqueda = $request->get('busqueda');

            // Filtrar por rol
            if ($rol && $rol !== 'todos') {
                $usuarios = array_filter($usuarios, function($usuario) use ($rol) {
                    return isset($usuario['rol']) && $usuario['rol'] === $rol;
                });
            }

            // Filtrar por estado
            if ($estado !== null && $estado !== 'todos') {
                $activo = $estado === 'activo';
                $usuarios = array_filter($usuarios, function($usuario) use ($activo) {
                    return isset($usuario['activo']) && $usuario['activo'] === $activo;
                });
            }

            // Filtrar por búsqueda (nombre, email o RUT)
            if ($busqueda) {
                $busquedaLower = strtolower($busqueda);
                $usuarios = array_filter($usuarios, function($usuario) use ($busquedaLower) {
                    $nombre = strtolower($usuario['displayName'] ?? '');
                    $email = strtolower($usuario['email'] ?? '');
                    $rut = strtolower($usuario['rut'] ?? '');
                    return str_contains($nombre, $busquedaLower) || 
                           str_contains($email, $busquedaLower) ||
                           str_contains($rut, $busquedaLower);
                });
            }

            // Re-indexar array después de filtros
            $usuarios = array_values($usuarios);

            // Ordenar por fecha de creación (más recientes primero)
            usort($usuarios, function($a, $b) {
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
                ];
            }, $usuarios);

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
     * Mostrar formulario de creación de usuario
     */
    public function create()
    {
        return Inertia::render('Usuarios/Create');
    }

    /**
     * Crear un nuevo usuario
     */
    public function store(Request $request)
    {
        // Validar datos del formulario
        $validated = $request->validate([
            'displayName' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'rut' => 'required|string|max:12',
            'telefono' => 'nullable|string|max:20',
            'rol' => 'required|in:admin,profesional,paciente',
            'password' => 'required|string|min:6|confirmed',
        ], [
            'displayName.required' => 'El nombre completo es obligatorio',
            'email.required' => 'El email es obligatorio',
            'email.email' => 'El email debe ser válido',
            'rut.required' => 'El RUT es obligatorio',
            'rol.required' => 'El rol es obligatorio',
            'rol.in' => 'El rol debe ser: admin, profesional o paciente',
            'password.required' => 'La contraseña es obligatoria',
            'password.min' => 'La contraseña debe tener al menos 6 caracteres',
            'password.confirmed' => 'Las contraseñas no coinciden',
        ]);

        try {
            logger()->info('🔵 Iniciando creación de usuario', ['email' => $validated['email']]);

            // Verificar que el email no esté en uso
            $usuarioModel = new Usuario();
            $emailExiste = $usuarioModel->findByEmail($validated['email']);
            
            if ($emailExiste) {
                logger()->warning('⚠️ Email ya registrado', ['email' => $validated['email']]);
                return back()
                    ->withErrors(['email' => 'Este email ya está registrado'])
                    ->withInput();
            }

            // Verificar que el RUT no esté en uso
            $usuarios = $usuarioModel->all();
            $rutExiste = collect($usuarios)->first(function($usuario) use ($validated) {
                return isset($usuario['rut']) && $usuario['rut'] === $validated['rut'];
            });

            if ($rutExiste) {
                logger()->warning('⚠️ RUT ya registrado', ['rut' => $validated['rut']]);
                return back()
                    ->withErrors(['rut' => 'Este RUT ya está registrado'])
                    ->withInput();
            }

            // Crear usuario en Firebase Auth
            logger()->info('📝 Creando usuario en Firebase Auth');
            $auth = app(FirebaseAuth::class);
            
            $userProperties = [
                'email' => $validated['email'],
                'password' => $validated['password'],
                'displayName' => $validated['displayName'],
                'emailVerified' => false,
            ];

            $firebaseUser = $auth->createUser($userProperties);
            $uid = $firebaseUser->uid;

            logger()->info('✅ Usuario creado en Firebase Auth', ['uid' => $uid]);

            // Crear documento en Firestore (usuarios)
            logger()->info('📝 Creando documento en Firestore');
            
            $usuarioData = [
                'id' => $uid,
                'displayName' => $validated['displayName'],
                'email' => $validated['email'],
                'rut' => $validated['rut'],
                'telefono' => $validated['telefono'] ?? null,
                'rol' => $validated['rol'],
                'activo' => true,
                'photoURL' => null,
                'emailVerified' => false,
                'createdAt' => now()->toISOString(),
                'updatedAt' => now()->toISOString(),
            ];

            $firestore = app(Firestore::class);
            $firestore->database()
                ->collection('usuarios')
                ->document($uid)
                ->set($usuarioData);

            logger()->info('✅ Usuario creado en Firestore', ['uid' => $uid]);

            // Si el rol es paciente o profesional, crear registro vinculado
            if ($validated['rol'] === 'paciente') {
                logger()->info('📝 Creando registro de paciente vinculado');
                
                $pacienteRef = $firestore->database()->collection('pacientes')->newDocument();
                $pacienteId = $pacienteRef->id();
                
                $pacienteData = [
                    'id' => $pacienteId,
                    'idUsuario' => $uid,
                    'createdAt' => now()->toISOString(),
                    'updatedAt' => now()->toISOString(),
                ];

                $pacienteRef->set($pacienteData);

                // Actualizar usuario con idPaciente
                $firestore->database()
                    ->collection('usuarios')
                    ->document($uid)
                    ->update([
                        ['path' => 'idPaciente', 'value' => $pacienteId],
                        ['path' => 'updatedAt', 'value' => now()->toISOString()],
                    ]);

                logger()->info('✅ Registro de paciente creado', ['idPaciente' => $pacienteId]);

                // Crear ficha médica vacía para el paciente
                logger()->info('📝 Creando ficha médica vacía para el paciente');
                
                $fichaRef = $firestore->database()->collection('fichasMedicas')->newDocument();
                $fichaId = $fichaRef->id();
                
                $fichaData = [
                    'id' => $fichaId,
                    'idPaciente' => $pacienteId,
                    'antecedentes' => [
                        'alergias' => [],
                        'familiares' => '',
                        'hospitalizaciones' => '',
                        'personales' => '',
                        'quirurgicos' => '',
                    ],
                    'observacion' => '',
                    'totalConsultas' => 0,
                    'ultimaConsulta' => null,
                    'fechaMedica' => now()->toISOString(),
                    'createdAt' => now()->toDateTime(),
                    'updatedAt' => now()->toDateTime(),
                ];

                $fichaRef->set($fichaData);

                logger()->info('✅ Ficha médica creada', ['idFicha' => $fichaId]);

            } elseif ($validated['rol'] === 'profesional') {
                logger()->info('📝 Creando registro de profesional vinculado');
                
                $profesionalRef = $firestore->database()->collection('profesionales')->newDocument();
                $profesionalId = $profesionalRef->id();
                
                $profesionalData = [
                    'id' => $profesionalId,
                    'idUsuario' => $uid,
                    'createdAt' => now()->toISOString(),
                    'updatedAt' => now()->toISOString(),
                ];

                $profesionalRef->set($profesionalData);

                // Actualizar usuario con idProfesional
                $firestore->database()
                    ->collection('usuarios')
                    ->document($uid)
                    ->update([
                        ['path' => 'idProfesional', 'value' => $profesionalId],
                        ['path' => 'updatedAt', 'value' => now()->toISOString()],
                    ]);

                logger()->info('✅ Registro de profesional creado', ['idProfesional' => $profesionalId]);
            }

            logger()->info('🎉 Usuario creado exitosamente', [
                'uid' => $uid,
                'email' => $validated['email'],
                'rol' => $validated['rol']
            ]);

            return redirect()
                ->route('usuarios.show', $uid)
                ->with('success', "Usuario {$validated['displayName']} creado exitosamente");

        } catch (\Kreait\Firebase\Exception\Auth\EmailExists $e) {
            logger()->error('❌ Email ya existe en Firebase Auth', [
                'email' => $validated['email'],
                'error' => $e->getMessage()
            ]);
            
            return back()
                ->withErrors(['email' => 'Este email ya está registrado en Firebase'])
                ->withInput();
        } catch (\Exception $e) {
            logger()->error('❌ Error creando usuario', [
                'email' => $validated['email'] ?? null,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return back()
                ->with('error', 'Error al crear usuario: ' . $e->getMessage())
                ->withInput();
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

            if (!$usuario) {
                return redirect()->route('usuarios.index')
                    ->with('error', 'Usuario no encontrado');
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
            $usuarioActual = $usuarioModel->find($id);
            
            if (!$usuarioActual) {
                return back()->with('error', 'Usuario no encontrado');
            }

            logger()->info("📋 Usuario actual obtenido", [
                'id' => $id,
                'email_actual' => $usuarioActual['email'] ?? null,
                'displayName_actual' => $usuarioActual['displayName'] ?? null
            ]);
            
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
            $usuario = $usuarioModel->find($id);

            if (!$usuario) {
                return back()->with('error', 'Usuario no encontrado');
            }

            $nuevoEstado = !($usuario['activo'] ?? false);
            
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
            $usuario = $usuarioModel->find($id);
            
            if (!$usuario) {
                return back()->with('error', 'Usuario no encontrado');
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
