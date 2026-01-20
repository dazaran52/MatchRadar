import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../theme/neon_theme.dart';
import '../widgets/glitch_text.dart';
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
          // Success
          final prefs = await SharedPreferences.getInstance();
          final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

          if (mounted) {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>
                onboardingDone ? const Dashboard() : const OnboardingScreen()
              )
            );
          }
        } else {
          _showSnack('Invalid Credentials', NeonTheme.neonRed);
        }
      } else {
        await DatabaseService().signUp(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text
        );
        _showSnack('Account Created', NeonTheme.neonGreen);
        setState(() => isLogin = true); // Switch to login after signup
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}', NeonTheme.neonRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color.withOpacity(0.8),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Logo Animation
                const Icon(FontAwesomeIcons.bolt, size: 60, color: Colors.white)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, color: NeonTheme.cyberCyan)
                    .shake(hz: 0.5, offset: const Offset(0, 0), rotation: 0.05), // Subtle float/shake

                const SizedBox(height: 16),

                const GlitchText('GLITCH',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 4)
                ),

                const SizedBox(height: 48),

                // Glass Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: NeonTheme.glassSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: !isLogin
                            ? Column(
                                key: const ValueKey('signup'),
                                children: [
                                  TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.person_outline, color: Colors.white54),
                                      hintText: 'Full Name',
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Name Required' : null,
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
                            prefixIcon: Icon(Icons.mail_outline, color: Colors.white54),
                            hintText: 'Email',
                          ),
                          validator: (v) => v!.contains('@') ? null : 'Invalid Email',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
                            hintText: 'Password',
                          ),
                          validator: (v) => v!.length < 6 ? 'Password too short' : null,
                        ),
                        const SizedBox(height: 32),

                        GradientButton(
                          text: isLogin ? 'LOG IN' : 'SIGN UP',
                          onTap: _submit,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: 0.1, end: 0, duration: 600.ms),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: FontAwesomeIcons.apple,
                      onTap: () => _showSnack('Apple Login Mock', NeonTheme.cyberCyan)
                    ),
                    const SizedBox(width: 24),
                    _SocialButton(
                      icon: FontAwesomeIcons.google,
                      onTap: () => _showSnack('Google Login Mock', NeonTheme.cyberCyan)
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                TextButton(
                  onPressed: _toggleMode,
                  child: RichText(
                    text: TextSpan(
                      style: NeonTheme.themeData.textTheme.bodyMedium,
                      children: [
                        TextSpan(text: isLogin ? "Don't have an account? " : "Already have an account? "),
                        TextSpan(
                          text: isLogin ? 'Sign Up' : 'Log In',
                          style: TextStyle(
                            color: NeonTheme.neonMagenta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
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
