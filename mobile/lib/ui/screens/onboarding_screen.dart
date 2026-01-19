import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/ble_service.dart';
import '../../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;
  String _status = "Welcome to Glitch";

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _status = "Requesting Access...";
    });

    final ble = BleService();
    bool granted = await ble.init();

    setState(() {
      _isLoading = false;
    });

    if (granted) {
      widget.onFinish();
    } else {
      setState(() {
        _status = "Permissions Denied.\nWe need Bluetooth & Location to find matches.";
      });
      // Fallback: Open settings
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radar, size: 100, color: AppTheme.primaryPink),
            const SizedBox(height: 30),
            Text("Enable Radar", style: AppTheme.titleStyle),
            const SizedBox(height: 20),
            Text(
              "Glitch uses Bluetooth and GPS to find people around you. Please grant permissions to start.",
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 50),
            if (_isLoading)
              const CircularProgressIndicator(color: AppTheme.primaryPurple)
            else
              ElevatedButton(
                onPressed: _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Allow Permissions", style: TextStyle(color: Colors.white)),
              ),
            const SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
