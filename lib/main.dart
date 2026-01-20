import 'package:flutter/material.dart';
import 'screens/auth_gate.dart';
import 'theme/neon_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional: Await DatabaseService().init() if we wanted to block start
  runApp(const GlitchApp());
}

class GlitchApp extends StatelessWidget {
  const GlitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glitch',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.themeData,
      home: const AuthGate(),
    );
  }
}
