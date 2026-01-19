import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/api_service.dart';
import '../../services/ble_service.dart';
import '../widgets/pulse_background.dart';
import '../widgets/user_avatar_bubble.dart';
import '../widgets/profile_card.dart';
import '../../utils/app_theme.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final ApiService _api = ApiService();
  final BleService _ble = BleService();

  List<User> _apiUsers = [];
  List<User> _bleUsers = [];
  User? _selectedUser;

  bool _isScanning = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
        Position position = await _determinePosition();
        final users = await _api.scanRadar(1, position.latitude, position.longitude);
        if (mounted) {
           setState(() {
             _apiUsers = users;
           });
        }

        if (!timer.tick.isEven) {
           _ble.stopScan();
           _ble.startScan();
        }

      } catch (e) {
        // Silent error
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
            // Convert BLE results to User objects
            List<User> scannedBleUsers = results.map((r) => User(
              id: 0, // 0 for BLE users
              name: r.device.platformName.isNotEmpty ? r.device.platformName : "Nearby Device",
              photoUrl: "https://ui-avatars.com/api/?name=${r.device.remoteId}&background=random",
              latitude: 0, longitude: 0
            )).toList();

            setState(() {
              _bleUsers = scannedBleUsers;
            });
          }
        });
      }
    } catch (e) {
      // Silent error
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Glitch", style: AppTheme.titleStyle),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause_circle_filled : Icons.play_circle_fill),
            color: Colors.white,
            iconSize: 30,
            onPressed: () => setState(() => _isScanning = !_isScanning),
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Background
          const PulseBackground(),

          // 2. People (Scattered for effect)
          // In a real app, we would map these to relative coordinates.
          // Here we use a LayoutBuilder to scatter them randomly but deterministically based on ID.
          LayoutBuilder(
            builder: (context, constraints) {
              final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

              final allUsers = [..._apiUsers, ..._bleUsers];

              return Stack(
                children: allUsers.map((user) {
                  // Pseudo-random position based on Name to keep it stable for BLE users (id=0)
                  final r = Random(user.id > 0 ? user.id : user.name.hashCode);
                  final angle = r.nextDouble() * 2 * pi;
                  final radius = 50.0 + r.nextDouble() * 150.0; // Distance from center

                  final dx = center.dx + cos(angle) * radius - 40; // -40 for avatar radius
                  final dy = center.dy + sin(angle) * radius - 40;

                  return Positioned(
                    left: dx,
                    top: dy,
                    child: UserAvatarBubble(
                      url: user.photoUrl,
                      isOnline: true,
                      onTap: () => setState(() => _selectedUser = user),
                    ),
                  );
                }).toList(),
              );
            }
          ),

          // 3. Status Pill
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  "${_apiUsers.length + _bleUsers.length} people nearby",
                  style: AppTheme.bodyStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),

          // 4. Selected User Card Overlay
          if (_selectedUser != null)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: ProfileCard(
                user: _selectedUser!,
                onClose: () => setState(() => _selectedUser = null),
              ),
            ),
        ],
      ),
    );
  }
}
