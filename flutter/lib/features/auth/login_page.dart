import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

/// Pantalla de inicio de sesión (PACIENTES)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _handleUserSelection(Usuario usuario) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithUsuario(usuario);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'No se pudo iniciar sesión'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
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
            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return IgnorePointer(
      ignoring: !_isLoading,
      child: AnimatedOpacity(
        opacity: _isLoading ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, minHeight: 520),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Text(
              'Selecciona un paciente para iniciar sesión rápidamente. '
              'Esta versión MVP no requiere contraseña.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _buildSearchField(),
            const SizedBox(height: 16),
            SizedBox(
              height: 360,
              child: _buildUserList(),
            ),
            const SizedBox(height: 16),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icono de paciente
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_rounded,
            size: 64,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nexus Medical',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Portal del Paciente',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: 'Buscar paciente por nombre, email o RUT',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    final authProvider = context.watch<AuthProvider>();

    return StreamBuilder<List<Usuario>>(
      stream: authProvider.pacientesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildStateMessage(
            icon: Icons.error_outline,
            color: Colors.red,
            message: 'Error al cargar pacientes: ${snapshot.error}',
          );
        }

        final usuarios = snapshot.data ?? [];
        final filtered = _filterUsuarios(usuarios);

        if (filtered.isEmpty) {
          return _buildStateMessage(
            icon: Icons.people_outline,
            color: Colors.grey,
            message: _searchQuery.isEmpty
                ? 'Aún no hay pacientes registrados.'
                : 'No encontramos coincidencias para "${_searchController.text}"',
            showRegisterHint: true,
          );
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final usuario = filtered[index];
            return _buildUserTile(usuario);
          },
        );
      },
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required Color color,
    required String message,
    bool showRegisterHint = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (showRegisterHint) ...[
            const SizedBox(height: 8),
            const Text(
              'Crea un paciente desde Ionic o usando el botón "Crear Nueva Cuenta".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTile(Usuario usuario) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: ListTile(
        enabled: !_isLoading,
        onTap: () => _handleUserSelection(usuario),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            usuario.nombre.isNotEmpty
                ? usuario.nombre.characters.first.toUpperCase()
                : '?',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(usuario.nombreCompleto),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email),
            if (usuario.rut.isNotEmpty)
              Text('RUT: ${usuario.rut}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.login, color: Colors.black54),
      ),
    );
  }

  List<Usuario> _filterUsuarios(List<Usuario> usuarios) {
    if (_searchQuery.isEmpty) return usuarios;
    return usuarios.where((usuario) {
      final nombre = usuario.nombreCompleto.toLowerCase();
      final email = usuario.email.toLowerCase();
      final rut = usuario.rut.toLowerCase();
      return nombre.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          rut.contains(_searchQuery);
    }).toList();
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: _isLoading
          ? null
          : () {
              context.go('/register');
            },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Crear Nueva Cuenta',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
