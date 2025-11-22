import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

enum ButtonType { primary, ghost, outline }

/// Botón personalizado que coincide con el estilo de la versión Ionic
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final bool isLoading;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              // ignore: deprecated_member_use
              return AppColors.primary.withValues(alpha: 0.5);
            }
            return AppColors.primary;
          }),
          shadowColor: WidgetStateProperty.all(
            // ignore: deprecated_member_use
            AppColors.primary.withValues(alpha: 0.18),
          ),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return 8;
            }
            return 4;
          }),
        );

      case ButtonType.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFCFE3FF)),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFF6FAFF);
            }
            return Colors.white;
          }),
        );

      case ButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.infoLight;
            }
            return Colors.transparent;
          }),
        );
    }
  }
}
