import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class CyberGlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double glitchProbability;
  final int speedMilliseconds;

  const CyberGlitchText(this.text, {
    super.key,
    this.style,
    this.glitchProbability = 0.03, // Low default
    this.speedMilliseconds = 100,
  });

  @override
  State<CyberGlitchText> createState() => _CyberGlitchTextState();
}

class _CyberGlitchTextState extends State<CyberGlitchText> {
  late String _displayText;
  late TextStyle? _currentStyle;
  Timer? _timer;
  final Random _random = Random();
  final String _chars = '!@#%^&*()_+-=[]{}|;:,.<>/?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    _currentStyle = widget.style;
    _startGlitchLoop();
  }

  void _startGlitchLoop() {
    _timer = Timer.periodic(Duration(milliseconds: widget.speedMilliseconds), (timer) {
      if (!mounted) return;

      if (_random.nextDouble() < widget.glitchProbability) {
        // Trigger Glitch Frame
        setState(() {
          _displayText = _glitchString(widget.text);
          // Occasionally change color for a frame
          if (_random.nextBool()) {
            _currentStyle = widget.style?.copyWith(
              color: _randomColor(),
              shadows: [
                Shadow(
                  color: _randomColor(),
                  offset: Offset(_random.nextDouble() * 4 - 2, _random.nextDouble() * 4 - 2),
                  blurRadius: 5
                )
              ]
            );
          }
        });

        // Reset quickly
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {
              _displayText = widget.text;
              _currentStyle = widget.style;
            });
          }
        });
      }
    });
  }

  String _glitchString(String input) {
    List<String> chars = input.split('');
    for (int i = 0; i < chars.length; i++) {
      if (_random.nextDouble() < 0.3) { // 30% chance to replace char during glitch frame
        chars[i] = _chars[_random.nextInt(_chars.length)];
      }
    }
    return chars.join();
  }

  Color _randomColor() {
    final colors = [
      NeonTheme.cyberCyan,
      NeonTheme.neonMagenta,
      NeonTheme.neonGreen,
      NeonTheme.neonRed,
      Colors.white,
      Colors.yellowAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: _currentStyle ?? widget.style,
      textAlign: TextAlign.center,
    );
  }
}
