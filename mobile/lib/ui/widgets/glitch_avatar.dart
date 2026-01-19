import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/glitch_theme.dart';

class GlitchAvatar extends StatelessWidget {
  final String name;
  final String url;
  final bool isBle;

  const GlitchAvatar({
    super.key,
    required this.name,
    required this.url,
    required this.isBle
  });

  @override
  Widget build(BuildContext context) {
    final color = isBle ? GlitchTheme.neonCyan : GlitchTheme.neonGreen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Target Brackets
        Stack(
          alignment: Alignment.center,
          children: [
             // Chromatic Aberration Effect (Simulated by offsetting layers)
            _buildAvatarLayer(color.withOpacity(0.7), const Offset(-2, 0)),
            _buildAvatarLayer(Colors.red.withOpacity(0.7), const Offset(2, 0)),
            _buildAvatarLayer(Colors.white, Offset.zero),

            // Rotating Brackets
            SizedBox(
              width: 90, height: 90,
              child: CircularProgressIndicator(
                value: 0.7,
                color: color,
                strokeWidth: 2,
              ),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: color.withOpacity(0.2),
          child: Text(
            name.toUpperCase(),
            style: GlitchTheme.terminalStyle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2
            )
          ),
        ).animate().fadeIn().shimmer(color: Colors.white),
      ],
    );
  }

  Widget _buildAvatarLayer(Color color, Offset offset) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(color, BlendMode.modulate),
          ),
        ),
      ),
    );
  }
}
