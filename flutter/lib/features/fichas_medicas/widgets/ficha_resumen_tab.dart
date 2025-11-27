import 'package:flutter/material.dart';
import '../../../models/paciente.dart';
import '../../../models/ficha_medica.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

/// Tab de resumen de la ficha médica
/// Muestra información demográfica, grupo sanguíneo, alergias y estado actual
class FichaResumenTab extends StatelessWidget {
  final Paciente paciente;
  final FichaMedica ficha;

  const FichaResumenTab({
    super.key,
    required this.paciente,
    required this.ficha,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de información del paciente
          _buildPatientInfoCard(),
          const SizedBox(height: 16),
          
          // Información médica básica
          _buildMedicalInfoCard(),
          const SizedBox(height: 16),
          
          // Alergias destacadas
          if (paciente.alergias != null && paciente.alergias!.isNotEmpty) ...[
            _buildAlleriesCard(),
            const SizedBox(height: 16),
          ],
          
          // Estado actual
          _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Información del Paciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('RUT', paciente.rut),
            _buildInfoRow(
              'Fecha de Nacimiento',
              paciente.fechaNacimiento != null
                  ? DateFormat('dd/MM/yyyy').format(paciente.fechaNacimiento!)
                  : 'No registrado',
            ),
            _buildInfoRow(
              'Edad',
              paciente.fechaNacimiento != null
                  ? '${_calculateAge(paciente.fechaNacimiento)} años'
                  : 'No disponible',
            ),
            _buildInfoRow('Sexo', paciente.sexo),
            _buildInfoRow('Teléfono', paciente.telefono),
            if (paciente.email != null && paciente.email!.isNotEmpty)
              _buildInfoRow('Email', paciente.email!),
            if (paciente.direccion.isNotEmpty)
              _buildInfoRow('Dirección', paciente.direccion),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Información Médica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                if (paciente.grupoSanguineo != null)
                  Expanded(
                    child: _buildHighlightBox(
                      'Grupo Sanguíneo',
                      paciente.grupoSanguineo!,
                      Colors.red,
                    ),
                  ),
                if (paciente.grupoSanguineo != null && paciente.estadoCivil != null)
                  const SizedBox(width: 12),
                if (paciente.estadoCivil != null)
                  Expanded(
                    child: _buildHighlightBox(
                      'Estado Civil',
                      paciente.estadoCivil!,
                      Colors.blue,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (paciente.enfermedadesCronicas != null && paciente.enfermedadesCronicas!.isNotEmpty) ...[
              const Text(
                'Enfermedades Crónicas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...paciente.enfermedadesCronicas!.map((enfermedad) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(enfermedad)),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],
            if (ficha.observacion != null && ficha.observacion!.isNotEmpty) ...[
              const Text(
                'Observaciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(ficha.observacion!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlleriesCard() {
    final alergias = paciente.alergias ?? [];
    
    return Card(
      elevation: 2,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Alergias Importantes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.red),
            ...alergias.map((alergia) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            alergia,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Estado Actual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (paciente.estado != null)
              _buildInfoRow('Estado del Paciente', paciente.estado!),
            if (ficha.createdAt != null)
              _buildInfoRow('Fecha de Creación de Ficha',
                  DateFormat('dd/MM/yyyy').format(ficha.createdAt!)),
            if (ficha.updatedAt != null)
              _buildInfoRow('Última Actualización',
                  DateFormat('dd/MM/yyyy HH:mm').format(ficha.updatedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
