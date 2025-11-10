import 'package:flutter/material.dart';
import '../../../models/consulta.dart';
import '../../../services/consultas_service.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

/// Tab de historial de consultas médicas
/// Muestra un timeline de todas las consultas ordenadas por fecha
class FichaHistorialTab extends StatelessWidget {
  final String fichaId;
  final String pacienteId;
  final _consultasService = ConsultasService();

  FichaHistorialTab({
    super.key,
    required this.fichaId,
    required this.pacienteId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Consulta>>(
      stream: _consultasService.getConsultasByPaciente(pacienteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text('Error al cargar el historial'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        }

        final consultas = snapshot.data ?? [];

        if (consultas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Sin Consultas Registradas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay consultas médicas para este paciente',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: consultas.length,
          itemBuilder: (context, index) {
            final consulta = consultas[index];
            final isFirst = index == 0;
            
            return _buildConsultaCard(context, consulta, isFirst);
          },
        );
      },
    );
  }

  Widget _buildConsultaCard(BuildContext context, Consulta consulta, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isFirst ? 4 : 2,
        color: isFirst ? Colors.blue[50] : null,
        child: InkWell(
          onTap: () {
            // TODO: Navegar a detalle de consulta
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Detalle de consulta - Por implementar'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con fecha y badge
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: isFirst ? Colors.blue[700] : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(consulta.fecha),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFirst ? Colors.blue[900] : null,
                      ),
                    ),
                    const Spacer(),
                    if (isFirst)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'MÁS RECIENTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Motivo de consulta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motivo de Consulta',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            consulta.motivoConsulta,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Diagnóstico principal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagnóstico',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            consulta.diagnosticoPrincipal,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Signos vitales (si existen)
                if (consulta.signosVitales.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (consulta.signosVitales['presionArterial'] != null)
                        _buildVitalSign(
                          Icons.favorite,
                          'PA',
                          consulta.signosVitales['presionArterial'],
                          Colors.red,
                        ),
                      if (consulta.signosVitales['frecuenciaCardiaca'] != null)
                        _buildVitalSign(
                          Icons.monitor_heart,
                          'FC',
                          '${consulta.signosVitales['frecuenciaCardiaca']} bpm',
                          Colors.pink,
                        ),
                      if (consulta.signosVitales['temperatura'] != null)
                        _buildVitalSign(
                          Icons.thermostat,
                          'Temp',
                          '${consulta.signosVitales['temperatura']}°C',
                          Colors.orange,
                        ),
                      if (consulta.signosVitales['saturacionO2'] != null)
                        _buildVitalSign(
                          Icons.air,
                          'SpO₂',
                          '${consulta.signosVitales['saturacionO2']}%',
                          Colors.blue,
                        ),
                    ],
                  ),
                ],
                
                // Footer con profesional
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      consulta.medicoNombre,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalSign(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
