import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      'title': 'WELCOME TO\nTHE GLITCH',
      'desc': 'You have entered the network. Connect with other rogue signals in your vicinity.',
      'icon': FontAwesomeIcons.mask,
    },
    {
      'title': 'LOCATION\nACCESS',
      'desc': 'We need your coordinates to find nearby matches. Your location is encrypted.',
      'icon': FontAwesomeIcons.locationArrow,
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
    final status = await perm.request();

    if (status.isGranted) {
      _nextPage();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      // Handle denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission required to proceed completely.')),
      );
      // Optional: still allow next page? For now, yes, to not block the user in prototype.
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

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard())
    );
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
                  physics: const NeverScrollableScrollPhysics(), // Force user to click buttons
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            page['icon'],
                            size: 80,
                            color: NeonTheme.cyberCyan,
                          ),
                          const SizedBox(height: 40),
                          GlitchText(
                            page['title'],
                            style: NeonTheme.themeData.textTheme.displayMedium,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page['desc'],
                            textAlign: TextAlign.center,
                            style: NeonTheme.themeData.textTheme.bodyLarge,
                          ),
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
                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? NeonTheme.cyberCyan
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    GradientButton(
                      text: _currentPage == _pages.length - 1
                          ? 'ENTER NETWORK'
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
                    if (_currentPage > 0) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text('SKIP PROTOCOL', style: TextStyle(color: Colors.white54)),
                      )
                    ]
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
