import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/citas_service.dart';
import '../../utils/app_colors.dart';

/// Página para ver y gestionar citas médicas del paciente
class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}

class _MisCitasPageState extends State<MisCitasPage> {
  final CitasService _citasService = CitasService();

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
          title: const Text('Mis Citas'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Próximas'),
              Tab(text: 'Pasadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de Citas Próximas
            StreamBuilder<List<Cita>>(
              stream: _citasService.obtenerCitasProximas(usuario.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final citas = snapshot.data ?? [];
                return _buildCitasList(citas, esProxima: true);
              },
            ),

            // Pestaña de Citas Pasadas
            StreamBuilder<List<Cita>>(
              stream: _citasService.obtenerCitasPasadas(usuario.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final citas = snapshot.data ?? [];
                return _buildCitasList(citas, esProxima: false);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _mostrarDialogoNuevaCita(context);
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Cita'),
        ),
      ),
    );
  }

  Widget _buildCitasList(List<Cita> citas, {required bool esProxima}) {
    if (citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              esProxima ? 'No tienes citas próximas' : 'No hay citas pasadas',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              esProxima ? 'Agenda una cita con el botón +'  : '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return _buildCitaCard(cita, esProxima: esProxima);
      },
    );
  }

  Widget _buildCitaCard(Cita cita, {required bool esProxima}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalleCita(cita),
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
                      color: _getEstadoColor(cita.estado).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event,
                      color: _getEstadoColor(cita.estado),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cita.especialidad,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cita.medico ?? 'Médico por asignar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildEstadoChip(cita.estado),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatFecha(cita.fecha),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    cita.hora,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (esProxima && cita.estado != EstadoCita.cancelada) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _cancelarCita(cita),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(EstadoCita estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getEstadoColor(estado),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getEstadoTexto(estado),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.confirmada:
        return Colors.green;
      case EstadoCita.pendiente:
        return Colors.orange;
      case EstadoCita.completada:
        return Colors.blue;
      case EstadoCita.cancelada:
        return Colors.red;
    }
  }

  String _getEstadoTexto(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
    }
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  void _mostrarDetalleCita(Cita cita) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    Icons.event,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.especialidad,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildEstadoChip(cita.estado),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.person, 'Médico', cita.medico ?? 'Por asignar'),
            const SizedBox(height: 12),
            _buildDetailRow(
                Icons.calendar_today, 'Fecha', _formatFecha(cita.fecha)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Hora', cita.hora),
            if (cita.observaciones != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.notes, 'Observaciones', cita.observaciones!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _cancelarCita(Cita cita) {
    if (cita.id == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta cita?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                await _citasService.cancelarCita(cita.id!);
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cita cancelada')),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Error al cancelar: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevaCita(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agendar Nueva Cita'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Para agendar una nueva cita, por favor contacta con tu centro médico.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
