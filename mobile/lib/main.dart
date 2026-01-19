import 'package:flutter/material.dart';
import 'ui/screens/radar_screen.dart';
import 'utils/glitch_theme.dart';

void main() {
  runApp(const GlitchApp());
}

class GlitchApp extends StatelessWidget {
  const GlitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glitch',
      debugShowCheckedModeBanner: false,
      theme: GlitchTheme.themeData,
      home: const RadarScreen(),
    );
  }
}
