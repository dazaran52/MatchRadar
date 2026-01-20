import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/database_service.dart';
import '../theme/neon_theme.dart';
import '../widgets/cyber_glitch_text.dart';
import '../widgets/gradient_button.dart';
import '../widgets/neo_glass.dart';
import '../widgets/shine_background.dart';
import 'onboarding_screen.dart';
import 'dashboard.dart';
import 'radar_dashboard.dart'; // Will exist later

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
          _handleSuccess('ACCESS GRANTED');
        } else {
          _showSnack('Invalid Credentials', NeonTheme.neonRed);
        }
      } else {
        await DatabaseService().signUp(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text
        );
        _handleSuccess('IDENTITY REGISTERED');
        // setState(() => isLogin = true);
      }
    } catch (e) {
      _showSnack('SYSTEM ERROR: ${e.toString()}', NeonTheme.neonRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccess(String msg) async {
    _showSnack(msg, NeonTheme.neonGreen);

    // Wait for snackbar
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) =>
        onboardingDone ? const RadarDashboard() : const OnboardingScreen()
      )
    );
  }

  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Attempt sign in
      final result = await _googleSignIn.signIn();
      if (result != null) {
        _handleSuccess('GOOGLE UPLINK ESTABLISHED');
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      _showSnack('Uplink Failed. Missing google-services.json?', NeonTheme.neonRed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _appleLogin() async {
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.identityToken != null) {
         _handleSuccess('APPLE UPLINK ESTABLISHED');
      }
    } catch (e) {
      print('Apple Sign In Error: $e');
      _showSnack('Apple Uplink Failed', NeonTheme.neonRed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: NeoGlass(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
             children: [
               Icon(color == NeonTheme.neonGreen ? Icons.check_circle : Icons.error, color: color),
               const SizedBox(width: 12),
               Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
             ],
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShineBackground(
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

                // Animated Logo
                const Icon(FontAwesomeIcons.bolt, size: 60, color: Colors.white)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms, color: NeonTheme.cyberCyan)
                    .shake(hz: 0.5, offset: const Offset(0, 0), rotation: 0.05),

                const SizedBox(height: 16),

                const CyberGlitchText(
                  'GLITCH',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white),
                  glitchProbability: 0.08, // Higher twitch on auth
                  speedMilliseconds: 50,
                ),

                const SizedBox(height: 48),

                NeoGlass(
                  borderRadius: 24,
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
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                                      hintText: 'CODENAME',
                                      filled: true,
                                      fillColor: Colors.black12,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.alternate_email, color: Colors.white54),
                            hintText: 'UPLINK (EMAIL)',
                            filled: true,
                            fillColor: Colors.black12,
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.contains('@') ? null : 'Invalid Uplink',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                            hintText: 'ACCESS KEY',
                            filled: true,
                            fillColor: Colors.black12,
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.length < 6 ? 'Weak Key' : null,
                        ),
                        const SizedBox(height: 32),

                        GradientButton(
                          text: isLogin ? 'INITIALIZE' : 'REGISTER',
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
                      onTap: _appleLogin
                    ),
                    const SizedBox(width: 24),
                    _SocialButton(
                      icon: FontAwesomeIcons.google,
                      onTap: _googleLogin
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Modern Switch Button
                OutlinedButton(
                  onPressed: _toggleMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NeonTheme.cyberCyan,
                    side: BorderSide(color: NeonTheme.cyberCyan.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(isLogin ? "CREATE NEW IDENTITY" : "ACCESS EXISTING NODE"),
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
          boxShadow: [
             BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
          ]
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
