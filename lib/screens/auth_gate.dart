import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/neon_theme.dart';
import '../widgets/glitch_text.dart';
import '../widgets/glass_box.dart';
import 'dashboard.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLoading = false;

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        final user = await DatabaseService().login(
          _emailCtrl.text.trim(),
          _passCtrl.text
        );

        if (user != null) {
          _showSnack('ACCESS GRANTED', NeonTheme.cyberCyan);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Dashboard())
            );
          }
        } else {
          _showSnack('ACCESS DENIED: Invalid Credentials', NeonTheme.neonMagenta);
        }
      } else {
        await DatabaseService().signUp(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text
        );
        _showSnack('IDENTITY REGISTERED', NeonTheme.cyberCyan);
        // Auto login or switch to login? Let's just switch to login for simplicity
        setState(() => isLogin = true);
      }
    } catch (e) {
      _showSnack('SYSTEM ERROR: ${e.toString()}', NeonTheme.neonMagenta);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(color: color, blurRadius: 10, spreadRadius: 1)
            ]
          ),
          child: Text(
            msg,
            style: NeonTheme.themeData.textTheme.bodyLarge?.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: NeonTheme.backgroundGradient,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GlitchText('NEON GLITCH\nNETWORK',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 4)
                ),
                const SizedBox(height: 48),
                CustomGlassBox(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: !isLogin
                            ? Column(
                                key: const ValueKey('signup'),
                                children: [
                                  TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'CODENAME',
                                      prefixIcon: Icon(Icons.person, color: NeonTheme.cyberCyan),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Identity Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              )
                            : const SizedBox.shrink(key: ValueKey('login')),
                        ),
                        TextFormField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'UPLINK (EMAIL)',
                            prefixIcon: Icon(Icons.email, color: NeonTheme.cyberCyan),
                          ),
                          validator: (v) => v!.contains('@') ? null : 'Invalid Uplink',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'ACCESS KEY',
                            prefixIcon: Icon(Icons.lock, color: NeonTheme.cyberCyan),
                          ),
                          validator: (v) => v!.length < 6 ? 'Key too short' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NeonTheme.cyberCyan,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                              ),
                              shadowColor: NeonTheme.cyberCyan,
                              elevation: 10,
                            ),
                            child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Text(isLogin ? 'INITIALIZE LINK' : 'ESTABLISH IDENTITY',
                                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            isLogin ? 'NEW NODE? REGISTER' : 'EXISTING NODE? LOGIN',
                            style: TextStyle(color: NeonTheme.neonMagenta),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
