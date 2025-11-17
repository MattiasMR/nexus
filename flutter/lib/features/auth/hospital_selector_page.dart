import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hospital.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

/// Pantalla para seleccionar hospital activo
/// Se muestra cuando el usuario tiene múltiples hospitales asignados
class HospitalSelectorPage extends StatelessWidget {
  const HospitalSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hospitals = authProvider.userHospitals;
    final currentUser = authProvider.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, currentUser?.displayName ?? ''),
              
              // Lista de hospitales
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: hospitals.isEmpty
                      ? _buildEmptyState()
                      : _buildHospitalsList(context, hospitals, authProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.local_hospital_rounded,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Bienvenido, $userName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona el hospital donde deseas trabajar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalsList(
    BuildContext context,
    List<Hospital> hospitals,
    AuthProvider authProvider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: hospitals.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        return _buildHospitalCard(context, hospital, authProvider);
      },
    );
  }

  Widget _buildHospitalCard(
    BuildContext context,
    Hospital hospital,
    AuthProvider authProvider,
  ) {
    return InkWell(
      onTap: () async {
        // Establecer hospital activo
        await authProvider.setActiveHospital(hospital);
        // La navegación se maneja automáticamente en main.dart
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono del hospital
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getHospitalIcon(hospital.tipo),
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            // Información del hospital
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hospital.ciudad}, ${hospital.region}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTipoColor(hospital.tipo).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTipoText(hospital.tipo),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTipoColor(hospital.tipo),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Icono de flecha
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.domain_disabled,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes hospitales asignados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contacta al administrador para obtener acceso',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helpers
  IconData _getHospitalIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'publico':
        return Icons.local_hospital;
      case 'privado':
        return Icons.business;
      case 'clinica':
        return Icons.medical_services;
      default:
        return Icons.domain;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'publico':
        return AppColors.primary;
      case 'privado':
        return AppColors.success;
      case 'clinica':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }

  String _getTipoText(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'publico':
        return 'Público';
      case 'privado':
        return 'Privado';
      case 'clinica':
        return 'Clínica';
      default:
        return tipo;
    }
  }
}
