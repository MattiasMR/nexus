import 'package:flutter/material.dart';
import '../../../models/alerta.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

/// Tab de alertas médicas
/// Muestra alertas importantes del paciente (alergias, medicación, citas, resultados críticos)
class FichaAlertasTab extends StatelessWidget {
  final String fichaId;
  final String pacienteId;

  const FichaAlertasTab({
    super.key,
    required this.fichaId,
    required this.pacienteId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar Stream desde Firestore cuando se cree el servicio de alertas
    // Por ahora mostramos un placeholder
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    // Alertas de ejemplo para mostrar el diseño
    final alertasEjemplo = [
      Alerta(
        id: '1',
        pacienteId: pacienteId,
        fichaId: fichaId,
        tipo: TipoAlerta.alergia,
        severidad: SeveridadAlerta.alta,
        titulo: 'Alergia a Penicilina',
        descripcion: 'Paciente presenta reacción alérgica severa a penicilina y derivados',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Alerta(
        id: '2',
        pacienteId: pacienteId,
        fichaId: fichaId,
        tipo: TipoAlerta.proximaCita,
        severidad: SeveridadAlerta.media,
        titulo: 'Control Próximo',
        descripcion: 'Control de presión arterial programado',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 5)),
        fechaExpiracion: DateTime.now().add(const Duration(days: 3)),
      ),
      Alerta(
        id: '3',
        pacienteId: pacienteId,
        fichaId: fichaId,
        tipo: TipoAlerta.medicacion,
        severidad: SeveridadAlerta.baja,
        titulo: 'Renovación de Receta',
        descripcion: 'Medicamento para hipertensión próximo a vencer',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
        fechaExpiracion: DateTime.now().add(const Duration(days: 7)),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header con estadísticas
        _buildStatsCard(alertasEjemplo),
        const SizedBox(height: 16),
        
        // Lista de alertas
        ...alertasEjemplo.map((alerta) => _buildAlertaCard(context, alerta)),
        
        // Mensaje informativo
        const SizedBox(height: 16),
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Las alertas se actualizan automáticamente desde el historial médico y citas programadas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(List<Alerta> alertas) {
    final criticas = alertas.where((a) => a.severidad == SeveridadAlerta.critica).length;
    final altas = alertas.where((a) => a.severidad == SeveridadAlerta.alta).length;
    final medias = alertas.where((a) => a.severidad == SeveridadAlerta.media).length;
    final bajas = alertas.where((a) => a.severidad == SeveridadAlerta.baja).length;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Resumen de Alertas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('Críticas', criticas, Colors.red),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox('Altas', altas, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox('Medias', medias, Colors.yellow[700]!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox('Bajas', bajas, Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaCard(BuildContext context, Alerta alerta) {
    final colorScheme = _getAlertaColorScheme(alerta.severidad);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: colorScheme['background'] as Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme['border'] as Color,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y severidad
              Row(
                children: [
                  Icon(
                    _getAlertaIcon(alerta.tipo),
                    color: colorScheme['icon'] as Color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alerta.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme['text'] as Color,
                      ),
                    ),
                  ),
                  _buildSeveridadBadge(alerta.severidad),
                ],
              ),
              const SizedBox(height: 12),
              
              // Descripción
              Text(
                alerta.descripcion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              
              // Fecha de expiración (si existe)
              if (alerta.fechaExpiracion != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Expira: ${DateFormat('dd/MM/yyyy').format(alerta.fechaExpiracion!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Footer con fecha de creación
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Creada: ${DateFormat('dd/MM/yyyy').format(alerta.fechaCreacion)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getTipoAlertaText(alerta.tipo),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeveridadBadge(SeveridadAlerta severidad) {
    final config = _getSeveridadConfig(severidad);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Map<String, dynamic> _getAlertaColorScheme(SeveridadAlerta severidad) {
    switch (severidad) {
      case SeveridadAlerta.critica:
        return {
          'background': Colors.red[50],
          'border': Colors.red[700],
          'icon': Colors.red[700],
          'text': Colors.red[900],
        };
      case SeveridadAlerta.alta:
        return {
          'background': Colors.orange[50],
          'border': Colors.orange[700],
          'icon': Colors.orange[700],
          'text': Colors.orange[900],
        };
      case SeveridadAlerta.media:
        return {
          'background': Colors.yellow[50],
          'border': Colors.yellow[700],
          'icon': Colors.yellow[800],
          'text': Colors.yellow[900],
        };
      case SeveridadAlerta.baja:
        return {
          'background': Colors.blue[50],
          'border': Colors.blue[700],
          'icon': Colors.blue[700],
          'text': Colors.blue[900],
        };
    }
  }

  Map<String, dynamic> _getSeveridadConfig(SeveridadAlerta severidad) {
    switch (severidad) {
      case SeveridadAlerta.critica:
        return {'label': 'CRÍTICA', 'color': Colors.red[700]};
      case SeveridadAlerta.alta:
        return {'label': 'ALTA', 'color': Colors.orange[700]};
      case SeveridadAlerta.media:
        return {'label': 'MEDIA', 'color': Colors.yellow[700]};
      case SeveridadAlerta.baja:
        return {'label': 'BAJA', 'color': Colors.blue[700]};
    }
  }

  IconData _getAlertaIcon(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.alergia:
        return Icons.warning_amber;
      case TipoAlerta.medicacion:
        return Icons.medication;
      case TipoAlerta.proximaCita:
        return Icons.event;
      case TipoAlerta.resultadoCritico:
        return Icons.science;
      case TipoAlerta.tratamiento:
        return Icons.local_hospital;
      case TipoAlerta.otro:
        return Icons.info;
    }
  }

  String _getTipoAlertaText(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.alergia:
        return 'Alergia';
      case TipoAlerta.medicacion:
        return 'Medicación';
      case TipoAlerta.proximaCita:
        return 'Próxima Cita';
      case TipoAlerta.resultadoCritico:
        return 'Resultado Crítico';
      case TipoAlerta.tratamiento:
        return 'Tratamiento';
      case TipoAlerta.otro:
        return 'Otro';
    }
  }
}
