import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CREATE ACCOUNT", style: AppTheme.titleStyle.copyWith(fontSize: 28)).animate().fadeIn(),
                  const SizedBox(height: 10),
                  const Text("Join the network.", style: TextStyle(color: Colors.white54)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 50),

                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                         TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDec("Full Name", Icons.person_outline),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDec("Email", Icons.email_outlined),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDec("Password", Icons.lock_outline),
                        ),
                        const SizedBox(height: 30),

                        if (auth.isLoading)
                          const CircularProgressIndicator(color: AppTheme.primaryPink)
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                bool success = await auth.signUp(_emailCtrl.text, _passCtrl.text, _nameCtrl.text);
                                if (success) {
                                   if (mounted) Navigator.pop(context); // Go back to login or auto-login
                                } else {
                                   if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Failed")));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ).animate().slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white54),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryPink)),
    );
  }
}
