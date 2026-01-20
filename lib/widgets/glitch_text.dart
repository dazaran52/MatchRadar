import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/neon_theme.dart';

class GlitchText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const GlitchText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    // Base Style
    final baseStyle = style ?? Theme.of(context).textTheme.displayLarge;
    final cyanStyle = baseStyle?.copyWith(color: NeonTheme.cyberCyan.withOpacity(0.8));
    final magentaStyle = baseStyle?.copyWith(color: NeonTheme.neonMagenta.withOpacity(0.8));

    return Stack(
      children: [
        // Layer 1: Magenta (Offset Left)
        Text(text, style: magentaStyle)
            .animate(onPlay: (controller) => controller.repeat())
            .shake(duration: 2000.ms, hz: 3, offset: const Offset(-2, 0)) // Slow jitter
            .tint(color: NeonTheme.neonMagenta, duration: 100.ms)
            .visibility(maintain: true, duration: 1500.ms)
            .toggle(builder: (_, value, child) => value ? child : const SizedBox()), // Random blink

        // Layer 2: Cyan (Offset Right)
        Text(text, style: cyanStyle)
            .animate(onPlay: (controller) => controller.repeat())
            .shake(duration: 2500.ms, hz: 2, offset: const Offset(2, 0))
            .visibility(maintain: true, duration: 2200.ms)
            .toggle(builder: (_, value, child) => value ? child : const SizedBox()),

        // Layer 3: White (Top, clear)
        Text(text, style: baseStyle)
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 3000.ms, color: Colors.white) // Scanning effect
      ],
    );
  }
}
