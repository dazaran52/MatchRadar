import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class GlitchTitle extends StatefulWidget {
  const GlitchTitle({super.key});

  @override
  State<GlitchTitle> createState() => _GlitchTitleState();
}

class _GlitchTitleState extends State<GlitchTitle> {
  String _text = "GLITCH";
  Timer? _timer;
  final String _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#\$%^&*()";

  @override
  void initState() {
    super.initState();
    _startGlitch();
  }

  void _startGlitch() {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) async {
      // Fast random shuffle
      for (int i = 0; i < 5; i++) {
        if (!mounted) break;
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {
          _text = String.fromCharCodes(Iterable.generate(6, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
        });
      }
      // Restore
      if (mounted) {
        setState(() => _text = "GLITCH");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: AppTheme.titleStyle.copyWith(
        fontSize: 40,
        letterSpacing: 5,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(color: AppTheme.primaryPink.withOpacity(0.8), offset: const Offset(-2, 0), blurRadius: 5),
          Shadow(color: Colors.cyanAccent.withOpacity(0.8), offset: const Offset(2, 0), blurRadius: 5),
        ]
      ),
    );
  }
}
