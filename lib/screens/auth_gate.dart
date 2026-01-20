import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_service.dart';
import '../theme/neon_theme.dart';
import '../widgets/glitch_text.dart';
import '../widgets/glass_box.dart';
import '../widgets/gradient_button.dart';
import 'onboarding_screen.dart';

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
      _formKey.currentState?.reset();
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
          _showSnack('ACCESS GRANTED', NeonTheme.neonGreen);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen())
            );
          }
        } else {
          _showSnack('ACCESS DENIED: Invalid Credentials', NeonTheme.neonRed);
        }
      } else {
        await DatabaseService().signUp(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text
        );
        _showSnack('IDENTITY REGISTERED', NeonTheme.neonGreen);
        setState(() => isLogin = true);
      }
    } catch (e) {
      _showSnack('SYSTEM ERROR: ${e.toString()}', NeonTheme.neonRed);
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)
            ]
          ),
          child: Row(
            children: [
              Icon(
                color == NeonTheme.neonGreen ? Icons.check_circle : Icons.error,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: NeonTheme.themeData.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
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
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const GlitchText('GLITCH',
                  style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, letterSpacing: 6)
                ),
                Text('FIND YOUR CYBER SOULMATE',
                  style: NeonTheme.themeData.textTheme.bodyMedium?.copyWith(
                    color: NeonTheme.cyberCyan,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),
                CustomGlassBox(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: !isLogin
                            ? Column(
                                key: const ValueKey('signup'),
                                children: [
                                  TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'CODENAME',
                                      prefixIcon: Icon(Icons.person_outline, color: NeonTheme.cyberCyan),
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
                            prefixIcon: Icon(Icons.alternate_email, color: NeonTheme.cyberCyan),
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
                            prefixIcon: Icon(Icons.lock_outline, color: NeonTheme.cyberCyan),
                          ),
                          validator: (v) => v!.length < 6 ? 'Key too short' : null,
                        ),
                        const SizedBox(height: 32),

                        GradientButton(
                          text: isLogin ? 'INITIALIZE LINK' : 'ESTABLISH IDENTITY',
                          onTap: _submit,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('OR CONNECT WITH', style: NeonTheme.themeData.textTheme.bodyMedium),
                            ),
                            const Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SocialButton(
                              icon: FontAwesomeIcons.google,
                              onTap: () => _showSnack('GOOGLE MODULE NOT LINKED', NeonTheme.neonMagenta),
                            ),
                            _SocialButton(
                              icon: FontAwesomeIcons.apple,
                              onTap: () => _showSnack('APPLE MODULE NOT LINKED', NeonTheme.neonMagenta),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _toggleMode,
                          child: RichText(
                            text: TextSpan(
                              style: NeonTheme.themeData.textTheme.bodyMedium,
                              children: [
                                TextSpan(text: isLogin ? "DON'T HAVE AN ID? " : "ALREADY REGISTERED? "),
                                TextSpan(
                                  text: isLogin ? 'REGISTER' : 'LOGIN',
                                  style: TextStyle(
                                    color: NeonTheme.cyberCyan,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
