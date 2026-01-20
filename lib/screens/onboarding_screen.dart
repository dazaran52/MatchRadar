import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/neon_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glitch_text.dart';
import 'dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'WELCOME TO\nGLITCH',
      'desc': 'The future of dating is here. Connect with signals that match your frequency.',
      'icon': FontAwesomeIcons.bolt,
    },
    {
      'title': 'LOCATION\nACCESS',
      'desc': 'We need your coordinates to find matches in your sector.',
      'icon': FontAwesomeIcons.locationDot,
      'permission': Permission.location,
    },
    {
      'title': 'NEARBY\nDEVICES',
      'desc': 'Scan for local signals using Bluetooth and Nearby protocols.',
      'icon': FontAwesomeIcons.wifi,
      'permission': Permission.nearbyWifiDevices,
    },
    {
      'title': 'CONTACTS\nSYNC',
      'desc': 'Find known operatives in your network.',
      'icon': FontAwesomeIcons.addressBook,
      'permission': Permission.contacts,
    },
  ];

  Future<void> _requestPermission(Permission? perm) async {
    if (perm == null) return;

    // Request permission
    // For Nearby Devices on Android 12+, we need check.
    final status = await perm.request();

    if (status.isGranted) {
      _nextPage();
    } else {
      // Proceed anyway for prototype
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission skipped for now.')),
      );
      _nextPage();
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: NeonTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                              border: Border.all(color: NeonTheme.cyberCyan.withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: NeonTheme.cyberCyan.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5
                                )
                              ]
                            ),
                            child: Icon(
                              page['icon'],
                              size: 60,
                              color: Colors.white,
                            ),
                          )
                          .animate(target: _currentPage == index ? 1 : 0)
                          .scale(duration: 500.ms, curve: Curves.elasticOut),

                          const SizedBox(height: 40),

                          GlitchText(
                            page['title'],
                            style: NeonTheme.themeData.textTheme.displayMedium,
                          ),

                          const SizedBox(height: 24),

                          Text(
                            page['desc'],
                            textAlign: TextAlign.center,
                            style: NeonTheme.themeData.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              color: Colors.white70
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? NeonTheme.neonMagenta
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    GradientButton(
                      text: _currentPage == _pages.length - 1
                          ? 'ENTER GLITCH'
                          : 'CONTINUE',
                      onTap: () {
                         final perm = _pages[_currentPage]['permission'] as Permission?;
                         if (perm != null) {
                           _requestPermission(perm);
                         } else {
                           _nextPage();
                         }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
