<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;
use App\Models\Usuario;
use App\Models\Paciente;
use App\Models\Profesional;
use App\Models\FichaMedica;

class ExportarBackup extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:export-backup 
                            {--force : Sobrescribir backup existente}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Exportar backup completo de la base de datos a JSON';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('💾 Iniciando exportación de backup...');
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->newLine();

        try {
            // Crear directorio de backup si no existe
            $timestamp = now()->format('Y-m-d_His');
            $backupDir = "backup/migration_{$timestamp}";
            
            if (!Storage::exists($backupDir)) {
                Storage::makeDirectory($backupDir);
            }

            // Exportar usuarios
            $this->info('👤 Exportando usuarios...');
            $usuarios = (new Usuario())->all();
            $this->exportarColeccion($usuarios, "{$backupDir}/usuarios.json");
            $this->info("   ✓ " . count($usuarios) . " usuarios exportados");
            $this->newLine();

            // Exportar pacientes
            $this->info('📋 Exportando pacientes...');
            $pacientes = (new Paciente())->all();
            $this->exportarColeccion($pacientes, "{$backupDir}/pacientes.json");
            $this->info("   ✓ " . count($pacientes) . " pacientes exportados");
            $this->newLine();

            // Exportar profesionales
            $this->info('👨‍⚕️ Exportando profesionales...');
            $profesionales = (new Profesional())->all();
            $this->exportarColeccion($profesionales, "{$backupDir}/profesionales.json");
            $this->info("   ✓ " . count($profesionales) . " profesionales exportados");
            $this->newLine();

            // Exportar fichas médicas
            $this->info('📄 Exportando fichas médicas...');
            $fichas = (new FichaMedica())->all();
            $this->exportarColeccion($fichas, "{$backupDir}/fichas_medicas.json");
            $this->info("   ✓ " . count($fichas) . " fichas médicas exportadas");
            $this->newLine();

            // Crear archivo de metadata
            $metadata = [
                'fecha_backup' => now()->toIso8601String(),
                'timestamp' => $timestamp,
                'totales' => [
                    'usuarios' => count($usuarios),
                    'pacientes' => count($pacientes),
                    'profesionales' => count($profesionales),
                    'fichas_medicas' => count($fichas),
                ],
                'ruta' => $backupDir,
            ];
            
            Storage::put("{$backupDir}/metadata.json", json_encode($metadata, JSON_PRETTY_PRINT));

            $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            $this->info('✅ Backup completado exitosamente');
            $this->newLine();
            $this->table(
                ['Colección', 'Registros'],
                [
                    ['Usuarios', count($usuarios)],
                    ['Pacientes', count($pacientes)],
                    ['Profesionales', count($profesionales)],
                    ['Fichas Médicas', count($fichas)],
                ]
            );
            $this->newLine();
            $this->info("📁 Ubicación: storage/app/{$backupDir}");
            
            return 0;

        } catch (\Exception $e) {
            $this->error('❌ Error durante la exportación: ' . $e->getMessage());
            $this->error($e->getTraceAsString());
            return 1;
        }
    }

    /**
     * Exportar colección a archivo JSON
     */
    protected function exportarColeccion(array $data, string $path): void
    {
        // Convertir timestamps de Firestore a strings
        $dataSerializable = array_map(function ($item) {
            return $this->convertirTimestamps($item);
        }, $data);

        Storage::put($path, json_encode($dataSerializable, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }

    /**
     * Convertir timestamps de Firestore a strings
     */
    protected function convertirTimestamps(array $data): array
    {
        foreach ($data as $key => $value) {
            if ($value instanceof \DateTime) {
                $data[$key] = $value->format('Y-m-d H:i:s');
            } elseif ($value instanceof \Google\Cloud\Core\Timestamp) {
                $data[$key] = $value->formatAsString();
            } elseif (is_array($value)) {
                $data[$key] = $this->convertirTimestamps($value);
            }
        }
        
        return $data;
    }
}
