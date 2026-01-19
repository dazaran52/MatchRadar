import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

class PulseBackground extends StatelessWidget {
  const PulseBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.bgGradient,
          ),
        ),

        // Soft Pulsing Ripples (Center)
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(period: 4.seconds))
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.5, 1.5),
                duration: 4.seconds,
                delay: (index * 1).seconds,
              )
              .fadeOut(duration: 4.seconds, delay: (index * 1).seconds);
            }),
          ),
        ),
      ],
    );
  }
}
