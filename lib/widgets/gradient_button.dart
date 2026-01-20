import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: NeonTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: NeonTheme.cyberCyan.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: NeonTheme.neonMagenta.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: NeonTheme.themeData.textTheme.labelLarge,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
