import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/glitch_theme.dart';

class CyberScanner extends StatefulWidget {
  final bool isScanning;
  const CyberScanner({super.key, required this.isScanning});

  @override
  State<CyberScanner> createState() => _CyberScannerState();
}

class _CyberScannerState extends State<CyberScanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isScanning) {
      return Center(
        child: Text("OFFLINE", style: GlitchTheme.headerStyle.copyWith(color: Colors.grey)),
      );
    }

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Radar Line
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: 0.5,
                      colors: [
                        Colors.transparent,
                        GlitchTheme.neonRed.withOpacity(0.1),
                        GlitchTheme.neonRed.withOpacity(0.5),
                      ],
                      stops: const [0.0, 0.9, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // Outer Circles
          Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GlitchTheme.neonRed.withOpacity(0.3), width: 1)
            ),
          ).animate(onPlay: (c) => c.repeat())
           .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut)
           .then().scale(begin: const Offset(1.05, 1.05), end: const Offset(0.95, 0.95), duration: 2.seconds),

          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GlitchTheme.neonRed.withOpacity(0.5), width: 1)
            ),
          ),

          // Random Numbers / Data Decor
          Positioned(
            bottom: 100,
            child: _RandomNumbers(),
          ),
        ],
      ),
    );
  }
}

class _RandomNumbers extends StatefulWidget {
  @override
  State<_RandomNumbers> createState() => _RandomNumbersState();
}

class _RandomNumbersState extends State<_RandomNumbers> {
  String text = "";

  @override
  void initState() {
    super.initState();
    _update();
  }

  void _update() async {
    while(mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) break;
      setState(() {
        text = "SCANNING FREQ: ${(Random().nextDouble() * 1000).toStringAsFixed(2)} MHz\n"
               "PACKETS: ${Random().nextInt(9999)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.center, style: GlitchTheme.dataStyle.copyWith(color: GlitchTheme.neonRed));
  }
}
