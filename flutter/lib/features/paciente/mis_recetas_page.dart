import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../services/recetas_service.dart';
import '../../services/receta_html_generator.dart';
import '../../models/medicamento.dart';
import '../../utils/app_colors.dart';

/// Página para ver recetas médicas del paciente
class MisRecetasPage extends StatefulWidget {
  const MisRecetasPage({super.key});

  @override
  State<MisRecetasPage> createState() => _MisRecetasPageState();
}

class _MisRecetasPageState extends State<MisRecetasPage> {
  final RecetasService _recetasService = RecetasService();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no encontrado')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Recetas'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Vigentes'),
              Tab(text: 'Anteriores'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecetasStream(usuario.id, esVigente: true),
            _buildRecetasStream(usuario.id, esVigente: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRecetasStream(String pacienteId, {required bool esVigente}) {
    return StreamBuilder<List<Receta>>(
      stream: esVigente
          ? _recetasService.obtenerRecetasVigentes(pacienteId)
          : _recetasService.obtenerRecetasAnteriores(pacienteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final recetas = snapshot.data ?? [];
        
        if (recetas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  esVigente
                      ? 'No tienes recetas vigentes'
                      : 'No hay recetas anteriores',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  esVigente
                      ? 'Tus recetas médicas aparecerán aquí'
                      : 'El historial de recetas vencidas aparecerá aquí',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recetas.length,
          itemBuilder: (context, index) {
            final receta = recetas[index];
            return _buildRecetaCard(receta);
          },
        );
      },
    );
  }

  Widget _buildRecetaCard(Receta receta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalleReceta(receta),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: receta.vigente
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: receta.vigente ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receta.nombreProfesional ?? 'Médico',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          receta.especialidadProfesional ?? 'Medicina General',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (receta.vigente)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Vigente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatFecha(receta.fecha),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.medical_services,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${receta.medicamentos.length} medicamento${receta.medicamentos.length > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Medicamentos:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...receta.medicamentos.map((med) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            med.nombreMedicamento,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleReceta(Receta receta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Receta Médica',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: receta.vigente ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            receta.vigente ? 'Vigente' : 'Vencida',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailSection('Información General', [
                _buildDetailRow('Médico', receta.nombreProfesional ?? 'No especificado'),
                _buildDetailRow('Especialidad', receta.especialidadProfesional ?? 'No especificado'),
                _buildDetailRow('Fecha', _formatFecha(receta.fecha)),
              ]),
              const SizedBox(height: 24),
              _buildDetailSection('Medicamentos Recetados', []),
              const SizedBox(height: 12),
              ...receta.medicamentos.map((med) => _buildMedicamentoCard(med)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _descargarReceta(receta),
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar Receta HTML'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentoCard(MedicamentoRecetado med) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    med.nombreMedicamento,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildMedDetailRow(Icons.schedule, 'Dosis', med.dosis),
            const SizedBox(height: 8),
            _buildMedDetailRow(Icons.schedule, 'Frecuencia', med.frecuencia),
            const SizedBox(height: 8),
            _buildMedDetailRow(Icons.timer, 'Duración', med.duracion),
            if (med.indicaciones != null) ...[  
              const SizedBox(height: 8),
              _buildMedDetailRow(Icons.info_outline, 'Indicaciones', med.indicaciones!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _descargarReceta(Receta receta) async {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;
    
    if (usuario == null) {
      _mostrarMensaje('Error: Usuario no encontrado');
      return;
    }

    try {
      _mostrarMensaje('Generando receta...');
      
      final filePath = await RecetaHtmlGenerator.guardarRecetaHtml(
        receta,
        nombrePaciente: usuario.nombreCompleto,
        rutPaciente: usuario.rut,
      );
      
      // Abrir el archivo HTML en el navegador
      final uri = Uri.file(filePath);
      final launched = await launchUrl(uri);
      
      if (launched) {
        if (!mounted) return;
        Navigator.pop(context); // Cerrar el modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receta guardada en:\n${filePath.split('/').last}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Abrir carpeta',
              onPressed: () async {
                // Abrir la carpeta contenedora
                final directory = filePath.substring(0, filePath.lastIndexOf('\\'));
                await launchUrl(Uri.file(directory));
              },
            ),
          ),
        );
      } else {
        _mostrarMensaje('Receta guardada pero no se pudo abrir automáticamente');
      }
    } catch (e) {
      _mostrarMensaje('Error al generar receta: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}


