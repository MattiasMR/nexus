import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../shared/widgets/weather_widget.dart';

/// Dashboard con estadísticas del sistema
class EstadisticasPage extends StatelessWidget {
  static const routeName = '/estadisticas';
  
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    if (!authService.puedeVerEstadisticas()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso Denegado')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'No tienes permisos para ver estadísticas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: WeatherWidget()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas generales
            _buildStatsGrid(),
            const SizedBox(height: 24),
            
            // Hospitalizaciones activas
            _buildActiveHospitalizaciones(),
            const SizedBox(height: 24),
            
            // Consultas recientes
            _buildRecentConsultas(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final db = FirebaseFirestore.instance;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Pacientes',
          Icons.people,
          Colors.blue,
          db.collection('pacientes').count(),
        ),
        _buildStatCard(
          'Consultas Hoy',
          Icons.event_note,
          Colors.green,
          db.collection('consultas')
              .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))
              .count(),
        ),
        _buildStatCard(
          'Hospitalizados',
          Icons.local_hospital,
          Colors.red,
          db.collection('hospitalizaciones')
              .where('fechaAlta', isNull: true)
              .count(),
        ),
        _buildStatCard(
          'Exámenes Pendientes',
          Icons.science,
          Colors.orange,
          db.collection('ordenes-examen')
              .where('estado', isEqualTo: 'pendiente')
              .count(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color, AggregateQuery query) {
    return FutureBuilder<AggregateQuerySnapshot>(
      future: query.get(),
      builder: (context, snapshot) {
        final count = snapshot.data?.count ?? 0;
        
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 12),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveHospitalizaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hospitalizaciones Activas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('hospitalizaciones')
              .where('fechaAlta', isNull: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay hospitalizaciones activas'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
                    ),
                    title: Text(data['motivoIngreso'] ?? 'Sin motivo'),
                    subtitle: Text('Hab: ${data['habitacion'] ?? 'N/A'}'),
                    trailing: Text(
                      '${(DateTime.now().difference((data['fechaIngreso'] as Timestamp).toDate()).inDays)} días',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentConsultas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultas Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('consultas')
              .orderBy('fecha', descending: true)
              .limit(10)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay consultas registradas'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final fecha = (data['fecha'] as Timestamp).toDate();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
                    ),
                    title: Text(data['motivoConsulta'] ?? 'Sin motivo'),
                    subtitle: Text(data['diagnosticoPrincipal'] ?? 'Sin diagnóstico'),
                    trailing: Text(
                      '${fecha.day}/${fecha.month}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
