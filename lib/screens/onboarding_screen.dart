import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/neon_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/cyber_glitch_text.dart';
import '../widgets/neo_glass.dart';
import '../widgets/shine_background.dart';
import 'radar_dashboard.dart';

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
      'desc': 'We killed the swipe. You are a signal in the void. Connect with others on the Radar.',
      'icon': FontAwesomeIcons.bolt,
    },
    {
      'title': 'LOCATION\nACCESS',
      'desc': 'To populate your Radar, we need your sector coordinates.',
      'icon': FontAwesomeIcons.locationDot,
      'permission': Permission.location,
    },
    {
      'title': 'NEARBY\nDEVICES',
      'desc': 'Scan for local nodes via Bluetooth/Wifi protocols.',
      'icon': FontAwesomeIcons.wifi,
      'permission': Permission.nearbyWifiDevices, // Or bluetoothScan
    },
    {
      'title': 'CONTACTS\nSYNC',
      'desc': 'Identify known operatives in your network.',
      'icon': FontAwesomeIcons.addressBook,
      'permission': Permission.contacts,
    },
  ];

  Future<void> _requestPermission(Permission? perm) async {
    if (perm == null) {
      _nextPage();
      return;
    }

    // Explicitly request
    print("Requesting permission: $perm");
    final status = await perm.request();
    print("Permission status: $status");

    if (status.isGranted || status.isLimited) {
      _nextPage();
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permission permanently denied. Please enable in settings.'),
            action: SnackBarAction(label: 'SETTINGS', onPressed: openAppSettings),
          ),
        );
      }
      // Don't block user flow for prototype
      Future.delayed(const Duration(seconds: 2), _nextPage);
    } else {
      // Denied but not permanent
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. Some features may be disabled.')),
        );
      }
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
        MaterialPageRoute(builder: (_) => const RadarDashboard())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShineBackground(
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeoGlass(
                            borderRadius: 100,
                            padding: const EdgeInsets.all(40),
                            child: Icon(
                              page['icon'],
                              size: 80,
                              color: Colors.white,
                            ),
                          )
                          .animate(target: _currentPage == index ? 1 : 0)
                          .scale(duration: 500.ms, curve: Curves.elasticOut),

                          const SizedBox(height: 40),

                          CyberGlitchText(
                            page['title'],
                            style: NeonTheme.themeData.textTheme.displayMedium,
                            glitchProbability: 0.05,
                          ),

                          const SizedBox(height: 24),

                          NeoGlass(
                            child: Text(
                              page['desc'],
                              textAlign: TextAlign.center,
                              style: NeonTheme.themeData.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                color: Colors.white70
                              ),
                            )
                          )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.2, end: 0),
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
                          ? 'ACTIVATE RADAR'
                          : 'ALLOW ACCESS',
                      onTap: () {
                         final perm = _pages[_currentPage]['permission'] as Permission?;
                         _requestPermission(perm);
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
