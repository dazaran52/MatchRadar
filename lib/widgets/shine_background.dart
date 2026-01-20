import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class ShineBackground extends StatefulWidget {
  final Widget child;
  const ShineBackground({super.key, required this.child});

  @override
  State<ShineBackground> createState() => _ShineBackgroundState();
}

class _ShineBackgroundState extends State<ShineBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Slow movement
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background
        Container(decoration: NeonTheme.backgroundGradient),

        // Moving Shine Beam
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FractionallySizedBox(
              widthFactor: 2.0, // Wider than screen
              heightFactor: 2.0,
              alignment: Alignment(_controller.value * 4 - 2, 0), // Move from left to right
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.5, 0.6],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Child content
        widget.child,
      ],
    );
  }
}
