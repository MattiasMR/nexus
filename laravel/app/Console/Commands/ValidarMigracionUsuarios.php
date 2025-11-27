<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Usuario;
use App\Models\Paciente;
use App\Models\Profesional;

class ValidarMigracionUsuarios extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:validate-migration';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Validar integridad de datos después de la migración';

    protected array $errores = [];
    protected array $advertencias = [];

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🔍 Validando integridad de la migración...');
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->newLine();

        // Validar pacientes
        $this->info('📋 Validando pacientes...');
        $this->validarPacientes();
        $this->newLine();

        // Validar profesionales
        $this->info('👨‍⚕️ Validando profesionales...');
        $this->validarProfesionales();
        $this->newLine();

        // Validar usuarios
        $this->info('👤 Validando usuarios...');
        $this->validarUsuarios();
        $this->newLine();

        // Mostrar resumen
        $this->mostrarResumen();

        return empty($this->errores) ? 0 : 1;
    }

    protected function validarPacientes(): void
    {
        $pacienteModel = new Paciente();
        $usuarioModel = new Usuario();
        
        $pacientes = $pacienteModel->all();
        $this->info("   Total pacientes: " . count($pacientes));

        $progressBar = $this->output->createProgressBar(count($pacientes));
        $progressBar->start();

        foreach ($pacientes as $paciente) {
            // 1. Verificar que tenga idUsuario
            if (empty($paciente['idUsuario'])) {
                $this->errores[] = "❌ Paciente {$paciente['id']} NO tiene idUsuario";
                $progressBar->advance();
                continue;
            }

            // 2. Verificar que el usuario exista
            $usuario = $usuarioModel->find($paciente['idUsuario']);
            if (!$usuario) {
                $this->errores[] = "❌ Paciente {$paciente['id']} apunta a usuario inexistente: {$paciente['idUsuario']}";
                $progressBar->advance();
                continue;
            }

            // 3. Verificar que el usuario tenga rol paciente
            if ($usuario['rol'] !== 'paciente') {
                $this->advertencias[] = "⚠️  Paciente {$paciente['id']} vinculado a usuario con rol '{$usuario['rol']}'";
            }

            // 4. Verificar que NO tenga campos duplicados
            $camposDuplicados = [];
            if (isset($paciente['email'])) $camposDuplicados[] = 'email';
            if (isset($paciente['rut'])) $camposDuplicados[] = 'rut';
            if (isset($paciente['telefono'])) $camposDuplicados[] = 'telefono';
            if (isset($paciente['nombre'])) $camposDuplicados[] = 'nombre';
            if (isset($paciente['apellido'])) $camposDuplicados[] = 'apellido';
            if (isset($paciente['nombreCompleto'])) $camposDuplicados[] = 'nombreCompleto';

            if (!empty($camposDuplicados)) {
                $this->errores[] = "❌ Paciente {$paciente['id']} tiene campos duplicados: " . implode(', ', $camposDuplicados);
            }

            // 5. Verificar referencia bidireccional
            if (empty($usuario['idPaciente']) || $usuario['idPaciente'] !== $paciente['id']) {
                $this->advertencias[] = "⚠️  Usuario {$usuario['id']} no apunta correctamente a paciente {$paciente['id']}";
            }

            $progressBar->advance();
        }

        $progressBar->finish();
        $this->newLine();
    }

    protected function validarProfesionales(): void
    {
        $profesionalModel = new Profesional();
        $usuarioModel = new Usuario();
        
        $profesionales = $profesionalModel->all();
        $this->info("   Total profesionales: " . count($profesionales));

        $progressBar = $this->output->createProgressBar(count($profesionales));
        $progressBar->start();

        foreach ($profesionales as $profesional) {
            // 1. Verificar que tenga idUsuario
            if (empty($profesional['idUsuario'])) {
                $this->errores[] = "❌ Profesional {$profesional['id']} NO tiene idUsuario";
                $progressBar->advance();
                continue;
            }

            // 2. Verificar que el usuario exista
            $usuario = $usuarioModel->find($profesional['idUsuario']);
            if (!$usuario) {
                $this->errores[] = "❌ Profesional {$profesional['id']} apunta a usuario inexistente: {$profesional['idUsuario']}";
                $progressBar->advance();
                continue;
            }

            // 3. Verificar que el usuario tenga rol profesional
            if ($usuario['rol'] !== 'profesional') {
                $this->advertencias[] = "⚠️  Profesional {$profesional['id']} vinculado a usuario con rol '{$usuario['rol']}'";
            }

            // 4. Verificar que NO tenga campos duplicados
            $camposDuplicados = [];
            if (isset($profesional['email'])) $camposDuplicados[] = 'email';
            if (isset($profesional['rut'])) $camposDuplicados[] = 'rut';
            if (isset($profesional['telefono'])) $camposDuplicados[] = 'telefono';
            if (isset($profesional['nombre'])) $camposDuplicados[] = 'nombre';
            if (isset($profesional['apellido'])) $camposDuplicados[] = 'apellido';

            if (!empty($camposDuplicados)) {
                $this->errores[] = "❌ Profesional {$profesional['id']} tiene campos duplicados: " . implode(', ', $camposDuplicados);
            }

            // 5. Verificar referencia bidireccional
            if (empty($usuario['idProfesional']) || $usuario['idProfesional'] !== $profesional['id']) {
                $this->advertencias[] = "⚠️  Usuario {$usuario['id']} no apunta correctamente a profesional {$profesional['id']}";
            }

            $progressBar->advance();
        }

        $progressBar->finish();
        $this->newLine();
    }

    protected function validarUsuarios(): void
    {
        $usuarioModel = new Usuario();
        $pacienteModel = new Paciente();
        $profesionalModel = new Profesional();
        
        $usuarios = $usuarioModel->all();
        $this->info("   Total usuarios: " . count($usuarios));

        $progressBar = $this->output->createProgressBar(count($usuarios));
        $progressBar->start();

        foreach ($usuarios as $usuario) {
            // 1. Verificar campos requeridos
            if (empty($usuario['email'])) {
                $this->errores[] = "❌ Usuario {$usuario['id']} sin email";
            }
            if (empty($usuario['displayName'])) {
                $this->errores[] = "❌ Usuario {$usuario['id']} sin displayName";
            }
            if (empty($usuario['rol'])) {
                $this->errores[] = "❌ Usuario {$usuario['id']} sin rol";
            }

            // 2. Verificar rol válido
            if (!in_array($usuario['rol'] ?? '', ['admin', 'profesional', 'paciente'])) {
                $this->errores[] = "❌ Usuario {$usuario['id']} tiene rol inválido: {$usuario['rol']}";
            }

            // 3. Verificar coherencia de referencias
            if ($usuario['rol'] === 'paciente') {
                if (empty($usuario['idPaciente'])) {
                    $this->advertencias[] = "⚠️  Usuario paciente {$usuario['id']} sin idPaciente";
                } else {
                    $paciente = $pacienteModel->find($usuario['idPaciente']);
                    if (!$paciente) {
                        $this->errores[] = "❌ Usuario {$usuario['id']} apunta a paciente inexistente: {$usuario['idPaciente']}";
                    }
                }
            }

            if ($usuario['rol'] === 'profesional') {
                if (empty($usuario['idProfesional'])) {
                    $this->advertencias[] = "⚠️  Usuario profesional {$usuario['id']} sin idProfesional";
                } else {
                    $profesional = $profesionalModel->find($usuario['idProfesional']);
                    if (!$profesional) {
                        $this->errores[] = "❌ Usuario {$usuario['id']} apunta a profesional inexistente: {$usuario['idProfesional']}";
                    }
                }
            }

            $progressBar->advance();
        }

        $progressBar->finish();
        $this->newLine();
    }

    protected function mostrarResumen(): void
    {
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->info('📊 RESUMEN DE VALIDACIÓN');
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->newLine();

        if (empty($this->errores) && empty($this->advertencias)) {
            $this->info('✅ VALIDACIÓN EXITOSA - No se encontraron problemas');
            return;
        }

        // Mostrar errores críticos
        if (!empty($this->errores)) {
            $this->error('❌ ERRORES CRÍTICOS (' . count($this->errores) . '):');
            foreach ($this->errores as $error) {
                $this->error('  ' . $error);
            }
            $this->newLine();
        }

        // Mostrar advertencias
        if (!empty($this->advertencias)) {
            $this->warn('⚠️  ADVERTENCIAS (' . count($this->advertencias) . '):');
            foreach ($this->advertencias as $advertencia) {
                $this->warn('  ' . $advertencia);
            }
            $this->newLine();
        }

        // Resumen final
        if (!empty($this->errores)) {
            $this->error('❌ Validación FALLIDA - Se encontraron ' . count($this->errores) . ' errores críticos');
        } else {
            $this->warn('⚠️  Validación con advertencias - Revisa los problemas menores');
        }
    }
}
