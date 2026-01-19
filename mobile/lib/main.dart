import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/screens/radar_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const GlitchApp());
}

class GlitchApp extends StatelessWidget {
  const GlitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar to light (white icons) for dark background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return MaterialApp(
      title: 'Glitch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const RadarScreen(),
    );
  }
}
