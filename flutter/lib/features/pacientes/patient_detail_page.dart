import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/paciente.dart';
import 'patient_form_page.dart';

class PatientDetailPage extends StatelessWidget {
  final Paciente paciente;

  const PatientDetailPage({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Paciente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            _buildSection(
              'Información Personal',
              [
                _buildInfoRow(Icons.badge, 'RUT', paciente.rut),
                _buildInfoRow(Icons.person, 'Nombre Completo', '${paciente.nombre} ${paciente.apellido}'),
                _buildInfoRow(Icons.cake, 'Fecha de Nacimiento', _formatDate(paciente.fechaNacimiento)),
                _buildInfoRow(Icons.trending_up, 'Edad', '${paciente.edad} años'),
                _buildInfoRow(Icons.wc, 'Sexo', paciente.sexo),
                if (paciente.grupoSanguineo != null)
                  _buildInfoRow(Icons.bloodtype, 'Grupo Sanguíneo', paciente.grupoSanguineo!),
                if (paciente.estadoCivil != null)
                  _buildInfoRow(Icons.favorite, 'Estado Civil', _formatEstadoCivil(paciente.estadoCivil!)),
              ],
            ),
            const Divider(height: 1),
            _buildSection(
              'Información de Contacto',
              [
                _buildInfoRow(Icons.home, 'Dirección', paciente.direccion),
                _buildInfoRow(Icons.phone, 'Teléfono', paciente.telefono),
                if (paciente.email != null && paciente.email!.isNotEmpty)
                  _buildInfoRow(Icons.email, 'Email', paciente.email!),
              ],
            ),
            const Divider(height: 1),
            _buildSection(
              'Información Adicional',
              [
                if (paciente.ocupacion != null && paciente.ocupacion!.isNotEmpty)
                  _buildInfoRow(Icons.work, 'Ocupación', paciente.ocupacion!),
                _buildInfoRow(
                  Icons.toggle_on,
                  'Estado',
                  paciente.estado ?? 'No especificado',
                  valueColor: (paciente.estado == 'activo') ? Colors.green : Colors.grey,
                ),
                if (paciente.diagnostico != null && paciente.diagnostico!.isNotEmpty)
                  _buildInfoRow(Icons.medical_services, 'Diagnóstico', paciente.diagnostico!),
              ],
            ),
            if (paciente.alergias != null && paciente.alergias!.isNotEmpty) ...[
              const Divider(height: 1),
              _buildListSection(
                'Alergias',
                paciente.alergias!,
                Icons.warning,
                Colors.orange,
              ),
            ],
            if (paciente.enfermedadesCronicas != null && paciente.enfermedadesCronicas!.isNotEmpty) ...[
              const Divider(height: 1),
              _buildListSection(
                'Enfermedades Crónicas',
                paciente.enfermedadesCronicas!,
                Icons.local_hospital,
                Colors.red,
              ),
            ],
            if (paciente.alertasMedicas != null && paciente.alertasMedicas!.isNotEmpty) ...[
              const Divider(height: 1),
              _buildAlertasSection(paciente.alertasMedicas!),
            ],
            const Divider(height: 1),
            _buildSection(
              'Metadatos',
              [
                if (paciente.createdAt != null)
                  _buildInfoRow(Icons.calendar_today, 'Fecha de Creación', _formatDateTime(paciente.createdAt!)),
                if (paciente.updatedAt != null)
                  _buildInfoRow(Icons.update, 'Última Actualización', _formatDateTime(paciente.updatedAt!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              paciente.iniciales,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${paciente.nombre} ${paciente.apellido}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'RUT: ${paciente.rut}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAlertasSection(List<AlertaMedica> alertas) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notification_important, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Alertas Médicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alertas.map((alerta) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: _getAlertColor(alerta.severidad),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getAlertIcon(alerta.tipo),
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatTipoAlerta(alerta.tipo),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            alerta.severidad.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alerta.descripcion,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Registrado: ${_formatDate(alerta.fechaRegistro)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Color _getAlertColor(String severidad) {
    switch (severidad) {
      case 'critica':
        return Colors.red[700]!;
      case 'alta':
        return Colors.orange[700]!;
      case 'media':
        return Colors.amber[700]!;
      default:
        return Colors.blue[700]!;
    }
  }

  IconData _getAlertIcon(String tipo) {
    switch (tipo) {
      case 'alergia':
        return Icons.warning;
      case 'enfermedad_cronica':
        return Icons.local_hospital;
      case 'medicamento_critico':
        return Icons.medication;
      default:
        return Icons.info;
    }
  }

  String _formatTipoAlerta(String tipo) {
    switch (tipo) {
      case 'alergia':
        return 'Alergia';
      case 'enfermedad_cronica':
        return 'Enfermedad Crónica';
      case 'medicamento_critico':
        return 'Medicamento Crítico';
      default:
        return 'Otra';
    }
  }

  String _formatEstadoCivil(String estado) {
    switch (estado) {
      case 'soltero':
        return 'Soltero/a';
      case 'casado':
        return 'Casado/a';
      case 'divorciado':
        return 'Divorciado/a';
      case 'viudo':
        return 'Viudo/a';
      case 'union_libre':
        return 'Unión Libre';
      default:
        return estado;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No registrado';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormPage(paciente: paciente),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente actualizado exitosamente')),
      );
    }
  }
}
