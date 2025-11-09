import 'package:flutter/material.dart';

/// Paleta de colores del sistema Nexus
/// Basada en el diseño de la versión Ionic
class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF176FDB);
  static const Color primaryLight = Color(0xFF52A6FF);
  static const Color primaryDark = Color(0xFF0D4FA3);
  
  // Colores de fondo
  static const Color background = Color(0xFFF7FBFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1F6FF);
  
  // Bordes y divisores
  static const Color border = Color(0xFFDBE8F7);
  static const Color borderLight = Color(0xFFE1ECFF);
  
  // Texto
  static const Color textPrimary = Color(0xFF0F1C2E);
  static const Color textSecondary = Color(0xFF6B7A90);
  static const Color textMuted = Color(0xFF9BB6DA);
  
  // Estados
  static const Color success = Color(0xFF2DBF7C);
  static const Color successLight = Color(0xFFE6F7EA);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF176FDB);
  static const Color infoLight = Color(0xFFE7F0FF);
  
  // Badges de estado
  static const Color badgeActivo = Color(0xFFE7F0FF);
  static const Color badgeActivoText = Color(0xFF176FDB);
  static const Color badgeEstable = Color(0xFFE6F7EA);
  static const Color badgeEstableText = Color(0xFF2DBF7C);
  static const Color badgeCritico = Color(0xFFFFE3E3);
  static const Color badgeCriticoText = Color(0xFFE53935);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
  
  // Sombras
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: const Color(0xFF174296).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
  
  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: const Color(0xFF174296).withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
  
  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: const Color(0xFF1F88FF).withOpacity(0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
}
