import 'package:flutter/material.dart';
import 'screens/auth_gate.dart';
import 'services/database_service.dart';
import 'theme/neon_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Note: We are initializing DB service here to fail early if connection is bad,
  // or we can do it lazily.
  // For this prototype, we'll try to init it but not block UI if it fails immediately
  // (unless we want to show a splash screen).
  // DatabaseService().init();

  runApp(const NeonGlitchApp());
}

class NeonGlitchApp extends StatelessWidget {
  const NeonGlitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Glitch Network',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.themeData,
      home: const AuthGate(),
    );
  }
}
