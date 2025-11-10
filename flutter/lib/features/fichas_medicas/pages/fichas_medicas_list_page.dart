import 'package:flutter/material.dart';
import '../../../models/paciente.dart';
import '../../../models/ficha_medica.dart';
import '../../../services/pacientes_service.dart';
import '../../../services/fichas_medicas_service.dart';
import '../../../shared/widgets/weather_widget.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'ficha_medica_detail_page.dart';

/// Página que lista todas las fichas médicas con acceso rápido
class FichasMedicasListPage extends StatefulWidget {
  static const routeName = '/fichas-medicas';
  
  const FichasMedicasListPage({super.key});

  @override
  State<FichasMedicasListPage> createState() => _FichasMedicasListPageState();
}

class _FichasMedicasListPageState extends State<FichasMedicasListPage> {
  final _pacientesService = PacientesService();
  final _fichasService = FichasMedicasService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fichas Médicas'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: WeatherWidget()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Paciente>>(
        stream: _searchQuery.isEmpty
            ? _pacientesService.getAllPacientes()
            : _pacientesService.searchPacientes(_searchQuery),
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
                  const Text('Error al cargar fichas médicas'),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final pacientes = snapshot.data ?? [];

          if (pacientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No hay fichas médicas registradas'
                        : 'No se encontraron resultados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return _buildFichaCard(context, paciente);
            },
          );
        },
      ),
    );
  }

  Widget _buildFichaCard(BuildContext context, Paciente paciente) {
    return FutureBuilder<FichaMedica?>(
      future: _fichasService.getFichaByPacienteId(paciente.id!),
      builder: (context, fichaSnapshot) {
        final ficha = fichaSnapshot.data;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              if (ficha != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FichaMedicaDetailPage(
                      paciente: paciente,
                      ficha: ficha,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ficha médica no encontrada'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con nombre y RUT
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          paciente.nombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${paciente.nombre} ${paciente.apellido}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RUT: ${paciente.rut}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  
                  // Información de la ficha
                  if (ficha != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            Icons.calendar_today,
                            'Última consulta',
                            ficha.ultimaConsulta != null
                                ? DateFormat('dd/MM/yyyy').format(ficha.ultimaConsulta!)
                                : 'Sin consultas',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoChip(
                            Icons.medical_services,
                            'Total consultas',
                            '${ficha.totalConsultas ?? 0}',
                          ),
                        ),
                      ],
                    ),
                  ] else if (fichaSnapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Ficha médica no disponible',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
