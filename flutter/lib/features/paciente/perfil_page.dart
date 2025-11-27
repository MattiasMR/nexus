import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/paciente.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

/// Página de perfil del paciente con edición inline
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _rutController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _previsionController;
  late TextEditingController _contactoEmergenciaController;
  late TextEditingController _telefonoEmergenciaController;

  DateTime? _selectedDate;
  String? _selectedSexo;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _hasHydrated = false;
  String? _lastHydrationKey;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _rutController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _previsionController = TextEditingController();
    _contactoEmergenciaController = TextEditingController();
    _telefonoEmergenciaController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _previsionController.dispose();
    _contactoEmergenciaController.dispose();
    _telefonoEmergenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pacienteCompleto = authProvider.pacienteCompleto;

    if (pacienteCompleto == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Información del paciente no disponible')),
      );
    }

    final usuario = pacienteCompleto.usuario;
    final paciente = pacienteCompleto.paciente;

    _maybeHydrateControllers(usuario, paciente);

    final showEmergencySection = _isEditing ||
        paciente.contactoEmergenciaNombre != null ||
        paciente.contactoEmergenciaTelefono != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : () => _cancelEditing(pacienteCompleto),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Perfil',
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(usuario.nombreCompleto),
                const SizedBox(height: 24),
                _buildSection(
                  'Información Personal',
                  [
                    _buildInfoField(
                      icon: Icons.person_outline,
                      label: 'Nombre Completo',
                      value: usuario.displayName,
                      controller: _nombreController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    _buildInfoField(
                      icon: Icons.badge_outlined,
                      label: 'RUT',
                      value: usuario.rut,
                      controller: _rutController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu RUT';
                        }
                        return null;
                      },
                    ),
                    _buildInfoTile(
                      Icons.email_outlined,
                      'Email',
                      usuario.email,
                    ),
                    _buildInfoField(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: usuario.telefono,
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu teléfono';
                        }
                        return null;
                      },
                    ),
                    _buildDatePickerField(
                      icon: Icons.cake_outlined,
                      label: 'Fecha de Nacimiento',
                      value: _selectedDate,
                    ),
                    _buildDropdownField(
                      icon: Icons.wc_outlined,
                      label: 'Sexo',
                      value: _selectedSexo,
                      items: ['Masculino', 'Femenino', 'Otro'],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  'Información Médica',
                  [
                    _buildInfoField(
                      icon: Icons.local_hospital_outlined,
                      label: 'Previsión',
                      value: paciente.prevision ?? 'No registrado',
                      controller: _previsionController,
                    ),
                    _buildInfoField(
                      icon: Icons.home_outlined,
                      label: 'Dirección',
                      value: paciente.direccion.isNotEmpty
                          ? paciente.direccion
                          : 'No registrado',
                      controller: _direccionController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (showEmergencySection)
                  _buildSection(
                    'Contacto de Emergencia',
                    [
                      _buildInfoField(
                        icon: Icons.contact_emergency_outlined,
                        label: 'Nombre',
                        value:
                            paciente.contactoEmergenciaNombre ?? 'No registrado',
                        controller: _contactoEmergenciaController,
                      ),
                      _buildInfoField(
                        icon: Icons.phone_in_talk_outlined,
                        label: 'Teléfono',
                        value: paciente.contactoEmergenciaTelefono ?? 'No registrado',
                        controller: _telefonoEmergenciaController,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _handleSave(authProvider, pacienteCompleto),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final confirm = await _mostrarDialogoConfirmacion(
                                context,
                                '¿Cerrar Sesión?',
                                '¿Estás seguro de que deseas cerrar sesión?',
                              );
                              if (confirm == true) {
                                await authProvider.signOut();
                              }
                            },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Versión 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nexus Medical © 2025',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _maybeHydrateControllers(Usuario usuario, Paciente paciente) {
    if (_isEditing) return;

    final hydrationKey = _composeHydrationKey(usuario, paciente);
    if (!_hasHydrated || _lastHydrationKey != hydrationKey) {
      _fillControllers(usuario, paciente);
      _lastHydrationKey = hydrationKey;
      _hasHydrated = true;
    }
  }

  String _composeHydrationKey(Usuario usuario, Paciente paciente) {
    final userUpdated = usuario.updatedAt?.millisecondsSinceEpoch ?? 0;
    final pacienteUpdated = paciente.updatedAt?.millisecondsSinceEpoch ?? 0;
    return '${usuario.id}_${userUpdated}_${paciente.id}_$pacienteUpdated';
  }

  void _fillControllers(Usuario usuario, Paciente paciente) {
    _nombreController.text = usuario.displayName;
    _rutController.text = usuario.rut;
    _telefonoController.text = usuario.telefono;
    _direccionController.text = paciente.direccion;
    _previsionController.text = paciente.prevision ?? '';
    _contactoEmergenciaController.text =
        paciente.contactoEmergenciaNombre ?? '';
    _telefonoEmergenciaController.text =
        paciente.contactoEmergenciaTelefono ?? '';
    
    _selectedDate = paciente.fechaNacimiento;
    _selectedSexo = paciente.sexo.isNotEmpty ? paciente.sexo : null;
  }

  void _cancelEditing(PacienteCompleto completo) {
    FocusScope.of(context).unfocus();
    _fillControllers(completo.usuario, completo.paciente);
    setState(() {
      _isEditing = false;
      _isSaving = false;
      _lastHydrationKey = _composeHydrationKey(
        completo.usuario,
        completo.paciente,
      );
    });
  }

  Future<void> _handleSave(
    AuthProvider authProvider,
    PacienteCompleto completo,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final success = await authProvider.updateProfile({
      'displayName': _nombreController.text.trim(),
      'rut': _rutController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'fechaNacimiento': _selectedDate,
      'sexo': _selectedSexo,
      'direccion': _emptyToNull(_direccionController.text),
      'prevision': _emptyToNull(_previsionController.text),
      'contactoEmergencia': _emptyToNull(_contactoEmergenciaController.text),
      'telefonoEmergencia': _emptyToNull(_telefonoEmergenciaController.text),
    });

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      setState(() => _isEditing = false);
      final refreshed = authProvider.pacienteCompleto ?? completo;
      _fillControllers(refreshed.usuario, refreshed.paciente);
      _lastHydrationKey = _composeHydrationKey(
        refreshed.usuario,
        refreshed.paciente,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error =
          authProvider.errorMessage ?? 'No se pudo actualizar el perfil';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Widget _buildHeader(String nombre) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(String titulo, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    if (_isEditing && controller != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          enabled: !_isSaving,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
      );
    }

    return _buildInfoTile(icon, label, value);
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'No registrado';
    try {
      return DateFormat('dd/MM/yyyy').format(fecha);
    } catch (_) {
      return 'No registrado';
    }
  }

  Future<bool?> _mostrarDialogoConfirmacion(
    BuildContext context,
    String titulo,
    String mensaje,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required IconData icon,
    required String label,
    required DateTime? value,
  }) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: !_isSaving
              ? () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: value ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
            ),
            child: Text(
              _formatFecha(value),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }
    return _buildInfoTile(icon, label, _formatFecha(value));
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
  }) {
    if (_isEditing) {
      // Ensure value is in items or null
      final effectiveValue = (value != null && items.contains(value)) ? value : null;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          initialValue: effectiveValue,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: !_isSaving
              ? (val) => setState(() => _selectedSexo = val)
              : null,
        ),
      );
    }
    return _buildInfoTile(
      icon,
      label,
      value != null && value.isNotEmpty ? value : 'No registrado',
    );
  }
}
