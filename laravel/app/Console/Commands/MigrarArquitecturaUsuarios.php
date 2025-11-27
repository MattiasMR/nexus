<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Usuario;
use App\Models\Paciente;
use App\Models\Profesional;
use Kreait\Firebase\Contract\Auth;
use Kreait\Firebase\Contract\Firestore;

class MigrarArquitecturaUsuarios extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'migrar:usuarios 
                            {--dry-run : Simular migración sin hacer cambios}
                            {--execute : Ejecutar migración real}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Migrar arquitectura de base de datos a modelo normalizado Usuario-Paciente-Profesional';

    protected Auth $auth;
    protected Firestore $firestore;
    protected bool $dryRun = true;
    
    protected array $stats = [
        'pacientes_procesados' => 0,
        'pacientes_con_usuario' => 0,
        'pacientes_usuario_creado' => 0,
        'profesionales_procesados' => 0,
        'profesionales_con_usuario' => 0,
        'profesionales_usuario_creado' => 0,
        'errores' => [],
    ];

    /**
     * Create a new command instance.
     */
    public function __construct(Auth $auth, Firestore $firestore)
    {
        parent::__construct();
        $this->auth = $auth;
        $this->firestore = $firestore;
    }

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🔄 Iniciando migración de arquitectura de base de datos');
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        // Determinar modo de ejecución
        if ($this->option('execute')) {
            $this->dryRun = false;
            $this->warn('⚠️  MODO EJECUCIÓN REAL - Se realizarán cambios en la base de datos');
            
            if (!$this->confirm('¿Estás seguro de que quieres continuar?')) {
                $this->error('❌ Migración cancelada');
                return 1;
            }
        } else {
            $this->dryRun = true;
            $this->info('ℹ️  MODO DRY-RUN - Solo simulación, no se harán cambios');
        }
        
        $this->newLine();
        
        try {
            // PASO 1: Migrar pacientes
            $this->info('📋 PASO 1: Procesando pacientes...');
            $this->migrarPacientes();
            
            $this->newLine();
            
            // PASO 2: Migrar profesionales
            $this->info('👨‍⚕️ PASO 2: Procesando profesionales...');
            $this->migrarProfesionales();
            
            $this->newLine();
            
            // PASO 3: Mostrar resumen
            $this->mostrarResumen();
            
            if (!$this->dryRun) {
                $this->newLine();
                $this->info('✅ Migración completada exitosamente');
                $this->warn('⚠️  Recuerda ejecutar: php artisan db:validate-migration');
            } else {
                $this->newLine();
                $this->info('ℹ️  Simulación completada. Ejecuta con --execute para aplicar cambios');
            }
            
            return 0;
            
        } catch (\Exception $e) {
            $this->error('❌ Error durante la migración: ' . $e->getMessage());
            $this->error($e->getTraceAsString());
            return 1;
        }
    }

    /**
     * Migrar pacientes existentes
     */
    protected function migrarPacientes(): void
    {
        $pacienteModel = new Paciente();
        $usuarioModel = new Usuario();
        
        $pacientes = $pacienteModel->all();
        $this->info("   Pacientes encontrados: " . count($pacientes));
        
        $progressBar = $this->output->createProgressBar(count($pacientes));
        $progressBar->start();
        
        foreach ($pacientes as $paciente) {
            $this->stats['pacientes_procesados']++;
            
            try {
                // Verificar si ya tiene idUsuario
                if (!empty($paciente['idUsuario'])) {
                    $this->stats['pacientes_con_usuario']++;
                    $progressBar->advance();
                    continue;
                }
                
                // Buscar usuario existente por email o RUT
                $usuario = null;
                
                if (!empty($paciente['email'])) {
                    $usuario = $usuarioModel->findByEmail($paciente['email']);
                }
                
                if (!$usuario && !empty($paciente['rut'])) {
                    $usuario = $usuarioModel->findByRut($paciente['rut']);
                }
                
                // Si no existe usuario, crear uno nuevo
                if (!$usuario) {
                    $this->stats['pacientes_usuario_creado']++;
                    
                    $usuarioData = $this->crearDatosUsuarioDePaciente($paciente);
                    
                    if (!$this->dryRun) {
                        // Crear usuario en Firebase Auth primero
                        try {
                            $firebaseUser = $this->auth->createUser([
                                'email' => $usuarioData['email'],
                                'password' => $this->generarPasswordTemporal(),
                                'displayName' => $usuarioData['displayName'],
                                'emailVerified' => false,
                            ]);
                            
                            // Crear en Firestore usando el UID de Firebase
                            $usuarioData['createdAt'] = new \DateTime();
                            $usuarioData['updatedAt'] = new \DateTime();
                            $usuarioData['ultimoAcceso'] = new \DateTime();
                            
                            $this->firestore
                                ->database()
                                ->collection('usuarios')
                                ->document($firebaseUser->uid)
                                ->set($usuarioData);
                            
                            $usuario = array_merge($usuarioData, ['id' => $firebaseUser->uid]);
                            
                        } catch (\Exception $e) {
                            $this->stats['errores'][] = "Error creando usuario para paciente {$paciente['id']}: {$e->getMessage()}";
                            $progressBar->advance();
                            continue;
                        }
                    } else {
                        // En modo dry-run, simular creación
                        $usuario = array_merge($usuarioData, ['id' => 'simulated-uid-' . uniqid()]);
                    }
                } else {
                    $this->stats['pacientes_con_usuario']++;
                }
                
                // Vincular paciente con usuario
                if (!$this->dryRun && $usuario) {
                    // Actualizar paciente con idUsuario
                    $this->firestore
                        ->database()
                        ->collection('pacientes')
                        ->document($paciente['id'])
                        ->set([
                            'idUsuario' => $usuario['id'],
                            'updatedAt' => new \DateTime(),
                        ], ['merge' => true]);
                    
                    // Actualizar usuario con idPaciente
                    $this->firestore
                        ->database()
                        ->collection('usuarios')
                        ->document($usuario['id'])
                        ->set([
                            'idPaciente' => $paciente['id'],
                            'updatedAt' => new \DateTime(),
                        ], ['merge' => true]);
                    
                    // Eliminar campos duplicados del paciente
                    $this->limpiarCamposDuplicadosPaciente($paciente['id']);
                }
                
            } catch (\Exception $e) {
                $this->stats['errores'][] = "Error procesando paciente {$paciente['id']}: {$e->getMessage()}";
            }
            
            $progressBar->advance();
        }
        
        $progressBar->finish();
        $this->newLine();
    }

    /**
     * Migrar profesionales existentes
     */
    protected function migrarProfesionales(): void
    {
        $profesionalModel = new Profesional($this->firestore);
        $usuarioModel = new Usuario();
        
        $profesionales = $profesionalModel->all();
        $this->info("   Profesionales encontrados: " . count($profesionales));
        
        $progressBar = $this->output->createProgressBar(count($profesionales));
        $progressBar->start();
        
        foreach ($profesionales as $profesional) {
            $this->stats['profesionales_procesados']++;
            
            try {
                // Verificar si ya tiene idUsuario
                if (!empty($profesional['idUsuario'])) {
                    $this->stats['profesionales_con_usuario']++;
                    $progressBar->advance();
                    continue;
                }
                
                // Buscar usuario existente por email o RUT
                $usuario = null;
                
                if (!empty($profesional['email'])) {
                    $usuario = $usuarioModel->findByEmail($profesional['email']);
                }
                
                if (!$usuario && !empty($profesional['rut'])) {
                    $usuario = $usuarioModel->findByRut($profesional['rut']);
                }
                
                // Si no existe usuario, crear uno nuevo
                if (!$usuario) {
                    $this->stats['profesionales_usuario_creado']++;
                    
                    $usuarioData = $this->crearDatosUsuarioDeProfesional($profesional);
                    
                    if (!$this->dryRun) {
                        try {
                            $firebaseUser = $this->auth->createUser([
                                'email' => $usuarioData['email'],
                                'password' => $this->generarPasswordTemporal(),
                                'displayName' => $usuarioData['displayName'],
                                'emailVerified' => false,
                            ]);
                            
                            $usuarioData['createdAt'] = new \DateTime();
                            $usuarioData['updatedAt'] = new \DateTime();
                            
                            $this->firestore
                                ->database()
                                ->collection('usuarios')
                                ->document($firebaseUser->uid)
                                ->set($usuarioData);
                            
                            $usuario = array_merge($usuarioData, ['id' => $firebaseUser->uid]);
                            
                        } catch (\Exception $e) {
                            $this->stats['errores'][] = "Error creando usuario para profesional {$profesional['id']}: {$e->getMessage()}";
                            $progressBar->advance();
                            continue;
                        }
                    } else {
                        $usuario = array_merge($usuarioData, ['id' => 'simulated-uid-' . uniqid()]);
                    }
                } else {
                    $this->stats['profesionales_con_usuario']++;
                }
                
                // Vincular profesional con usuario
                if (!$this->dryRun && $usuario) {
                    $this->firestore
                        ->database()
                        ->collection('profesionales')
                        ->document($profesional['id'])
                        ->set([
                            'idUsuario' => $usuario['id'],
                            'updatedAt' => new \DateTime(),
                        ], ['merge' => true]);
                    
                    $this->firestore
                        ->database()
                        ->collection('usuarios')
                        ->document($usuario['id'])
                        ->set([
                            'idProfesional' => $profesional['id'],
                            'updatedAt' => new \DateTime(),
                        ], ['merge' => true]);
                    
                    $this->limpiarCamposDuplicadosProfesional($profesional['id']);
                }
                
            } catch (\Exception $e) {
                $this->stats['errores'][] = "Error procesando profesional {$profesional['id']}: {$e->getMessage()}";
            }
            
            $progressBar->advance();
        }
        
        $progressBar->finish();
        $this->newLine();
    }

    /**
     * Crear datos de usuario a partir de paciente
     */
    protected function crearDatosUsuarioDePaciente(array $paciente): array
    {
        return [
            'email' => $paciente['email'] ?? 'paciente.' . uniqid() . '@temporal.nexus.cl',
            'displayName' => $paciente['nombreCompleto'] ?? 
                            ($paciente['nombre'] ?? '') . ' ' . ($paciente['apellido'] ?? 'Paciente'),
            'rut' => $paciente['rut'] ?? null,
            'telefono' => $paciente['telefono'] ?? null,
            'rol' => 'paciente',
            'activo' => $paciente['activo'] ?? true,
        ];
    }

    /**
     * Crear datos de usuario a partir de profesional
     */
    protected function crearDatosUsuarioDeProfesional(array $profesional): array
    {
        return [
            'email' => $profesional['email'] ?? 'profesional.' . uniqid() . '@temporal.nexus.cl',
            'displayName' => ($profesional['nombre'] ?? '') . ' ' . ($profesional['apellido'] ?? 'Profesional'),
            'rut' => $profesional['rut'] ?? null,
            'telefono' => $profesional['telefono'] ?? null,
            'rol' => 'profesional',
            'activo' => $profesional['activo'] ?? true,
        ];
    }

    /**
     * Generar password temporal
     */
    protected function generarPasswordTemporal(): string
    {
        return 'Temporal' . rand(1000, 9999) . '!';
    }

    /**
     * Limpiar campos duplicados del paciente
     */
    protected function limpiarCamposDuplicadosPaciente(string $pacienteId): void
    {
        $camposAEliminar = [
            'nombre' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'apellido' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'nombreCompleto' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'rut' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'email' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'telefono' => \Google\Cloud\Firestore\FieldValue::deleteField(),
        ];
        
        $this->firestore
            ->database()
            ->collection('pacientes')
            ->document($pacienteId)
            ->set($camposAEliminar, ['merge' => true]);
    }

    /**
     * Limpiar campos duplicados del profesional
     */
    protected function limpiarCamposDuplicadosProfesional(string $profesionalId): void
    {
        $camposAEliminar = [
            'nombre' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'apellido' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'rut' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'email' => \Google\Cloud\Firestore\FieldValue::deleteField(),
            'telefono' => \Google\Cloud\Firestore\FieldValue::deleteField(),
        ];
        
        $this->firestore
            ->database()
            ->collection('profesionales')
            ->document($profesionalId)
            ->set($camposAEliminar, ['merge' => true]);
    }

    /**
     * Mostrar resumen de la migración
     */
    protected function mostrarResumen(): void
    {
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->info('📊 RESUMEN DE MIGRACIÓN');
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        $this->table(
            ['Métrica', 'Valor'],
            [
                ['Pacientes procesados', $this->stats['pacientes_procesados']],
                ['Pacientes con usuario existente', $this->stats['pacientes_con_usuario']],
                ['Usuarios creados para pacientes', $this->stats['pacientes_usuario_creado']],
                ['', ''],
                ['Profesionales procesados', $this->stats['profesionales_procesados']],
                ['Profesionales con usuario existente', $this->stats['profesionales_con_usuario']],
                ['Usuarios creados para profesionales', $this->stats['profesionales_usuario_creado']],
                ['', ''],
                ['Total errores', count($this->stats['errores'])],
            ]
        );
        
        if (!empty($this->stats['errores'])) {
            $this->newLine();
            $this->error('⚠️  Errores encontrados:');
            foreach ($this->stats['errores'] as $error) {
                $this->error('  - ' . $error);
            }
        }
    }
}
