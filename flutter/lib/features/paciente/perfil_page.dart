import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _previsionController;
  late TextEditingController _contactoEmergenciaController;
  late TextEditingController _telefonoEmergenciaController;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _hasHydrated = false;
  String? _lastUserId;
  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _previsionController = TextEditingController();
    _contactoEmergenciaController = TextEditingController();
    _telefonoEmergenciaController = TextEditingController();
  }

  @override
  void dispose() {
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
    final usuario = authProvider.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no encontrado')),
      );
    }

    _maybeHydrateControllers(usuario);

    final showEmergencySection = _isEditing ||
        usuario.contactoEmergencia != null ||
        usuario.telefonoEmergencia != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : () => _cancelEditing(usuario),
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
                    _buildInfoTile(
                      Icons.person_outline,
                      'Nombre Completo',
                      usuario.nombreCompleto,
                    ),
                    _buildInfoTile(
                      Icons.badge_outlined,
                      'RUT',
                      usuario.rut,
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
                    _buildInfoTile(
                      Icons.cake_outlined,
                      'Fecha de Nacimiento',
                      usuario.fechaNacimiento != null
                          ? _formatFecha(usuario.fechaNacimiento!)
                          : 'No registrado',
                    ),
                    _buildInfoTile(
                      Icons.wc_outlined,
                      'Sexo',
                      usuario.sexo ?? 'No registrado',
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
                      value: usuario.prevision ?? 'No registrado',
                      controller: _previsionController,
                    ),
                    _buildInfoField(
                      icon: Icons.home_outlined,
                      label: 'Dirección',
                      value: usuario.direccion ?? 'No registrado',
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
                        value: usuario.contactoEmergencia ?? 'No registrado',
                        controller: _contactoEmergenciaController,
                      ),
                      _buildInfoField(
                        icon: Icons.phone_in_talk_outlined,
                        label: 'Teléfono',
                        value: usuario.telefonoEmergencia ?? 'No registrado',
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
                          : () => _handleSave(authProvider, usuario),
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

  void _maybeHydrateControllers(Usuario usuario) {
    final hasChanged =
        _lastUserId != usuario.id || _lastUpdatedAt != usuario.updatedAt;

    if (!_isEditing && !_hasHydrated) {
      _fillControllers(usuario);
      _hasHydrated = true;
      return;
    }

    if (hasChanged && !_isEditing) {
      _fillControllers(usuario);
    }
  }

  void _fillControllers(Usuario usuario) {
    _telefonoController.text = usuario.telefono;
    _direccionController.text = usuario.direccion ?? '';
    _previsionController.text = usuario.prevision ?? '';
    _contactoEmergenciaController.text = usuario.contactoEmergencia ?? '';
    _telefonoEmergenciaController.text = usuario.telefonoEmergencia ?? '';
    _lastUserId = usuario.id;
    _lastUpdatedAt = usuario.updatedAt;
  }

  void _cancelEditing(Usuario usuario) {
    FocusScope.of(context).unfocus();
    _fillControllers(usuario);
    setState(() {
      _isEditing = false;
      _isSaving = false;
    });
  }

  Future<void> _handleSave(AuthProvider authProvider, Usuario usuario) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final success = await authProvider.updateProfile({
      'telefono': _telefonoController.text.trim(),
      'direccion': _emptyToNull(_direccionController.text),
      'prevision': _emptyToNull(_previsionController.text),
      'contactoEmergencia': _emptyToNull(_contactoEmergenciaController.text),
      'telefonoEmergencia': _emptyToNull(_telefonoEmergenciaController.text),
    });

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      setState(() => _isEditing = false);
      final refreshedUser = authProvider.currentUser ?? usuario;
      _fillControllers(refreshedUser);
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

  String _formatFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
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
}
