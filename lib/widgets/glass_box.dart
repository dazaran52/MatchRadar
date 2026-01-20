import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  GradientBorderPainter({required this.radius, required this.strokeWidth, required this.gradient});

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(strokeWidth/2, strokeWidth/2, size.width - strokeWidth, size.height - strokeWidth);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = strokeWidth;
    _paint.shader = gradient.createShader(rect);
    canvas.drawRRect(rRect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CustomGlassBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final List<Color> borderGradientColors;

  const CustomGlassBox({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.borderGradientColors = const [Color(0xFF00F0FF), Color(0xFFD900FF)],
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: CustomPaint(
          painter: borderColor != null
              ? null
              : GradientBorderPainter(
                  radius: 16,
                  strokeWidth: 1.5,
                  gradient: LinearGradient(
                    colors: borderGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
          child: Container(
            decoration: BoxDecoration(
              color: NeonTheme.glassSurface,
              borderRadius: BorderRadius.circular(16),
              border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
