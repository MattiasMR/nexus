import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ficha_medica_service.dart';
import '../../models/ficha_medica.dart';
import '../../utils/app_colors.dart';

/// Página para ver la ficha médica del paciente
class MiFichaMedicaPage extends StatefulWidget {
  const MiFichaMedicaPage({super.key});

  @override
  State<MiFichaMedicaPage> createState() => _MiFichaMedicaPageState();
}

class _MiFichaMedicaPageState extends State<MiFichaMedicaPage> {
  final FichaMedicaService _fichaService = FichaMedicaService();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ficha Médica'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<FichaMedica?>(
        stream: _fichaService.escucharFichaMedica(usuario.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final ficha = snapshot.data;

          if (ficha == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontró tu ficha médica',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consulta con tu médico para crearla',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con datos del paciente
                _buildHeaderCard(usuario.nombreCompleto, usuario.rut),
                const SizedBox(height: 16),

                // Información básica
                _buildSectionTitle('Información Básica'),
                const SizedBox(height: 8),
                _buildInfoCard([
                  _InfoItem(
                    icon: Icons.bloodtype,
                    label: 'Grupo Sanguíneo',
                    value: ficha.grupoSanguineo ?? 'No registrado',
                  ),
                  _InfoItem(
                    icon: Icons.calendar_today,
                    label: 'Última Consulta',
                    value: ficha.ultimaConsulta != null
                        ? _formatDate(ficha.ultimaConsulta!)
                        : 'Sin consultas',
                  ),
                ]),
                const SizedBox(height: 16),

                // Alergias
                _buildSectionTitle('Alergias'),
                const SizedBox(height: 8),
                _buildAlergiasCard(ficha.alergias),
                const SizedBox(height: 16),

                // Antecedentes
                _buildSectionTitle('Antecedentes Médicos'),
                const SizedBox(height: 8),
                _buildAntecedentesCard(ficha.antecedentes),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(String nombre, String rut) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RUT: $rut',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(item.icon, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlergiasCard(List<String> alergias) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: alergias.isEmpty
            ? const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text(
                    'Sin alergias registradas',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alergias.map((alergia) {
                  return Chip(
                    avatar: const Icon(Icons.warning_amber, size: 18),
                    label: Text(alergia),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(fontSize: 13),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildAntecedentesCard(Antecedentes? antecedentes) {
    if (antecedentes == null || antecedentes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[400]),
              const SizedBox(width: 12),
              const Text(
                'Sin antecedentes registrados',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (antecedentes.personales != null)
          _buildAntecedenteItem(
            'Personales',
            antecedentes.personales!,
            Icons.person_outline,
          ),
        if (antecedentes.familiares != null) ...[
          const SizedBox(height: 8),
          _buildAntecedenteItem(
            'Familiares',
            antecedentes.familiares!,
            Icons.family_restroom,
          ),
        ],
        if (antecedentes.quirurgicos != null) ...[
          const SizedBox(height: 8),
          _buildAntecedenteItem(
            'Quirúrgicos',
            antecedentes.quirurgicos!,
            Icons.local_hospital,
          ),
        ],
        if (antecedentes.hospitalizaciones != null) ...[
          const SizedBox(height: 8),
          _buildAntecedenteItem(
            'Hospitalizaciones',
            antecedentes.hospitalizaciones!,
            Icons.hotel,
          ),
        ],
      ],
    );
  }

  Widget _buildAntecedenteItem(String titulo, String descripcion, IconData icon) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
