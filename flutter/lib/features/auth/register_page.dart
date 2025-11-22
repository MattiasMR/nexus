import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

/// Pantalla de registro de nuevos pacientes
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _rutController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      rut: _rutController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      // La navegación a home se maneja automáticamente por go_router
    } else {
      // Error en registro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al crear cuenta'),
          backgroundColor: Colors.red,
        ),
      );
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Crear Cuenta'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildRegisterCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos Personales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 24),

              // Nombre
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Apellido
              _buildTextField(
                controller: _apellidoController,
                label: 'Apellido',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // RUT
              _buildTextField(
                controller: _rutController,
                label: 'RUT',
                hint: '12345678-9',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu RUT';
                  }
                  // Validación básica de formato RUT
                  if (!RegExp(r'^\d{7,8}-[\dkK]$').hasMatch(value.trim())) {
                    return 'Formato inválido (ej: 12345678-9)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Teléfono
              _buildTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                hint: '+56912345678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Divider
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Credenciales de Acceso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 24),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Correo Electrónico',
                hint: 'ejemplo@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo electrónico';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              _buildPasswordField(
                controller: _passwordController,
                label: 'Contraseña',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirmar Contraseña',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Terms and conditions
              _buildTermsCheckbox(),
              const SizedBox(height: 24),

              // Register button
              _buildRegisterButton(),
              const SizedBox(height: 16),

              // Back to login
              _buildBackToLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _acceptedTerms = value ?? false);
                },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Acepto los términos y condiciones de uso de la plataforma',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return Center(
      child: TextButton(
        onPressed: _isLoading
            ? null
            : () {
                context.go('/login');
              },
        child: Text(
          '¿Ya tienes cuenta? Inicia sesión',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
