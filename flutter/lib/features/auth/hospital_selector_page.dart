import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Pantalla de selección de hospital
/// NOTA: Esta app es solo para pacientes, no necesitan seleccionar hospital
/// Esta página redirige automáticamente al home
class HospitalSelectorPage extends StatelessWidget {
  const HospitalSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente ya que los pacientes no eligen hospital
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/');
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primaryLight,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
