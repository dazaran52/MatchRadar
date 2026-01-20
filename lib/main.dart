import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_gate.dart';
import 'theme/neon_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found. Database connection might fail.");
  }
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
