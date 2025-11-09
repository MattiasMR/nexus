import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'custom_button.dart';

/// Widget de estado vacío que coincide con el estilo de la versión Ionic
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final ButtonType buttonType;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.buttonType = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEAF3FF),
                  const Color(0xFFD4E9FF),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Título
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Mensaje
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Botón (opcional)
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: buttonText!,
              onPressed: onButtonPressed,
              type: buttonType,
              height: 44,
            ),
          ],
        ],
      ),
    );
  }
}
