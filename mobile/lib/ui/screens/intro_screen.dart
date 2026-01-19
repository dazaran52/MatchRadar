import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/ble_service.dart';
import '../../utils/app_theme.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const IntroScreen({super.key, required this.onFinish});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),

          PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              _buildPage(
                icon: Icons.radar,
                title: "Welcome to Glitch",
                desc: "The next-gen social radar. Find people around you in real-time using advanced hybrid location technology.",
              ),
              _buildPage(
                icon: Icons.bluetooth_audio,
                title: "Hyper-Local",
                desc: "We use Bluetooth Low Energy to detect users in the same room, even without GPS. Connect instantly.",
              ),
              _buildPermissionsPage(),
            ],
          ),

          // Indicators
          Positioned(
            bottom: 50, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 20 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primaryPink : Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppTheme.primaryPurple).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(title, style: AppTheme.titleStyle, textAlign: TextAlign.center).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 20),
          Text(desc, style: AppTheme.bodyStyle.copyWith(fontSize: 16), textAlign: TextAlign.center).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 80, color: AppTheme.primaryPink),
          const SizedBox(height: 30),
          Text("Enable Access", style: AppTheme.titleStyle),
          const SizedBox(height: 20),
          Text(
            "To find matches, Glitch needs access to your Location and Bluetooth. We do not track you when the app is closed.",
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              final ble = BleService();
              // This calls request() internally
              bool granted = await ble.init();
              if (granted) {
                widget.onFinish();
              } else {
                // If denied permanently, open settings
                 openAppSettings();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Grant Permissions", style: TextStyle(color: Colors.white, fontSize: 16)),
          ).animate().shimmer(delay: 1.seconds),
        ],
      ),
    );
  }
}
