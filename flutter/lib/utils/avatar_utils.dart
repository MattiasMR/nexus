import 'dart:math';
import 'package:flutter/material.dart';

/// Utilidades para generación de avatares y colores consistentes
class AvatarUtils {
  /// Paleta de colores para avatares
  static const List<Color> avatarColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFD32F2F), // Red
    Color(0xFFF57C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF0097A7), // Cyan
    Color(0xFFC2185B), // Pink
    Color(0xFF5D4037), // Brown
    Color(0xFF455A64), // Blue Grey
    Color(0xFF00796B), // Teal
    Color(0xFFE64A19), // Deep Orange
    Color(0xFF512DA8), // Deep Purple
  ];

  /// Obtiene las iniciales de un nombre
  static String getInitials(String? firstName, [String? lastName]) {
    if (firstName == null || firstName.isEmpty) return '?';
    
    final first = firstName.trim();
    final last = lastName?.trim() ?? '';
    
    final firstInitial = first.isNotEmpty ? first[0].toUpperCase() : '';
    final lastInitial = last.isNotEmpty ? last[0].toUpperCase() : '';
    
    if (firstInitial.isEmpty) return '?';
    if (lastInitial.isEmpty) return firstInitial;
    
    return '$firstInitial$lastInitial';
  }

  /// Obtiene un color consistente basado en el nombre
  static Color getAvatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    
    // Usar hash del nombre para obtener un índice consistente
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final index = hash.abs() % avatarColors.length;
    return avatarColors[index];
  }

  /// Obtiene el color del avatar como string hexadecimal
  static String getAvatarColorHex(String name) {
    final color = getAvatarColor(name);
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Genera un widget de avatar circular
  static Widget buildAvatar({
    required String name,
    double size = 48,
    double fontSize = 16,
    String? imageUrl,
  }) {
    final color = getAvatarColor(name);
    final initials = getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsWidget(initials, fontSize);
                },
              ),
            )
          : _buildInitialsWidget(initials, fontSize),
    );
  }

  /// Widget interno para mostrar iniciales
  static Widget _buildInitialsWidget(String initials, double fontSize) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  /// Genera un color aleatorio
  static Color randomColor() {
    final random = Random();
    return avatarColors[random.nextInt(avatarColors.length)];
  }
}
