import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/api_service.dart';
import '../../services/ble_service.dart';
import '../widgets/background_grid.dart';
import '../widgets/cyber_scanner.dart';
import '../widgets/glitch_avatar.dart';
import '../widgets/terminal_panel.dart';
import '../../utils/glitch_theme.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final ApiService _api = ApiService();
  final BleService _ble = BleService();

  List<User> _serverUsers = [];
  List<ScanResult> _bleDevices = [];

  bool _isScanning = true;
  Timer? _timer;
  String _statusLog = "SYSTEM INITIALIZED...";

  @override
  void initState() {
    super.initState();
    // Hide Status Bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initRadar();
  }

  void _initRadar() {
    _startGpsCycle();
    _initBle();
  }

  void _startGpsCycle() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isScanning) return;
      try {
        _log("ACQUIRING GPS LOCK...");
        Position position = await _determinePosition();

        _log("GPS LOCK: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}");

        final users = await _api.scanRadar(1, position.latitude, position.longitude);
        if (mounted) {
           setState(() {
             _serverUsers = users;
             if (users.isNotEmpty) _log("TARGETS DETECTED: ${users.length}");
           });

           // Simple Haptic Feedback on found
           if (users.isNotEmpty) HapticFeedback.mediumImpact();
        }

        // BLE Refresh
        if (!timer.tick.isEven) {
           _ble.stopScan();
           _ble.startScan();
        }

      } catch (e) {
        _log("GPS ERROR: $e");
      }
    });
  }

  Future<void> _initBle() async {
    try {
      bool bleReady = await _ble.init();
      if (bleReady) {
        _ble.startScan();
        _ble.scanResults.listen((results) {
          if (mounted) {
            setState(() {
              if (results.length > _bleDevices.length) {
                 HapticFeedback.heavyImpact();
                 _log("NEW BLE SIGNAL INTERCEPTED");
              }
              _bleDevices = results;
            });
          }
        });
      }
    } catch (e) {
      _log("BLE INIT ERROR: $e");
    }
  }

  void _log(String msg) {
    if (mounted) setState(() => _statusLog = ">> ${msg.toUpperCase()}");
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Disabled');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ble.stopScan();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Combine users for the terminal
    List<User> allUsers = [..._serverUsers];
    // Map BLE to dummy User objects for display consistency
    for (var b in _bleDevices) {
      allUsers.add(User(
        id: 0,
        name: b.device.platformName.isNotEmpty ? b.device.platformName : "UNKNOWN SIGNAL",
        photoUrl: "",
        latitude: 0, longitude: 0
      ));
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Digital Background
          const BackgroundGrid(),

          // 2. Scanner Animation
          CyberScanner(isScanning: _isScanning),

          // 3. Header / Log
          Positioned(
            top: 40, left: 20, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("GLITCH RADAR v2.0", style: GlitchTheme.headerStyle),
                Text(_statusLog, style: GlitchTheme.terminalStyle.copyWith(color: GlitchTheme.neonRed)),
              ],
            ),
          ),

          // 4. GPS Matches (Server)
          ..._serverUsers.map((user) {
             // Randomize position slightly for visual interest (mock) or use real logic to map coords to screen
             // For this visual overhaul, we'll stack them for now or use fixed relative offsets.
             // In a real AR view, we'd map lat/lng to screen x/y.
             // We'll simulate it by putting them in a fixed pattern.
             return Align(
               alignment: const Alignment(0, -0.3),
               child: GlitchAvatar(name: user.name, url: user.photoUrl, isBle: false),
             );
          }),

          // 5. BLE Matches
          ..._bleDevices.map((device) {
             return Align(
               alignment: const Alignment(0, 0.3),
               child: GlitchAvatar(
                 name: device.device.platformName,
                 url: "https://ui-avatars.com/api/?name=${device.device.remoteId}&background=00F0FF&color=000",
                 isBle: true
               ),
             );
          }),

          // 6. Terminal Bottom Sheet
          TerminalPanel(users: allUsers),

          // 7. Toggle Button
          Positioned(
            bottom: 20, right: 20,
            child: FloatingActionButton(
              backgroundColor: _isScanning ? GlitchTheme.neonRed : Colors.grey,
              onPressed: () => setState(() => _isScanning = !_isScanning),
              child: Icon(_isScanning ? Icons.stop : Icons.power_settings_new),
            ),
          ),
        ],
      ),
    );
  }
}
