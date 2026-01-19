import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

class AnimatedGradientBackground extends StatelessWidget {
  const AnimatedGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.midnightBlue,
            AppTheme.deepPurple,
            Color(0xFF4A00E0),
            Color(0xFF8E2DE2),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
    .shimmer(duration: 5.seconds, color: Colors.white10);
  }
}
