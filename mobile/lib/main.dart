import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'api_service.dart';
import 'ble_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatchRadar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
      ),
      home: const RadarScreen(),
    );
  }
}

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
  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initRadar();
  }

  void _initRadar() {
    // 1. СРАЗУ запускаем GPS (не ждем блютуз)
    _startGpsCycle();

    // 2. Пытаемся запустить BLE в фоне
    _initBle();
  }

  // 🔥 ВОТ ЭТА ФУНКЦИЯ, КОТОРАЯ ПОТЕРЯЛАСЬ
  void _startGpsCycle() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isScanning) return;
      try {
        Position position = await _determinePosition();
        if (mounted) {
           setState(() => _statusMessage = "GPS Active: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}");
        }
        
        // Отправляем на сервер
        final users = await _api.scanRadar(1, position.latitude, position.longitude);
        if (mounted) setState(() => _serverUsers = users);
        
        // Перезапускаем скан BLE для свежести данных (если он доступен)
        if (!timer.tick.isEven) { 
           _ble.stopScan();
           _ble.startScan();
        }

      } catch (e) {
        print("GPS Error: $e");
      }
    });
  }

  Future<void> _initBle() async {
    try {
      // Инициализируем, но не блокируем работу, если юзер отказал
      bool bleReady = await _ble.init();
      if (bleReady) {
        _ble.startScan();
        _ble.scanResults.listen((results) {
          if (mounted) {
            setState(() {
              _bleDevices = results;
            });
          }
        });
      }
    } catch (e) {
      print("BLE init error: $e");
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
    int totalFound = _serverUsers.length + _bleDevices.length;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
             // Анимация радара
            if (_isScanning)
            ...List.generate(3, (index) {
              return Container(
                width: 300, height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2)),
              ).animate(onPlay: (c) => c.repeat()).scale(duration: 2.seconds, delay: (index * 600).ms, begin: const Offset(0.1, 0.1), end: const Offset(1.5, 1.5)).fadeOut(duration: 2.seconds, delay: (index * 600).ms);
            }),

            const Icon(Icons.location_on, color: Colors.white, size: 50),

            // Статус
            Positioned(
              top: 50,
              child: Column(
                children: [
                  Text(_statusMessage, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text("Found: $totalFound", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),

            // Server Users (Green)
            Positioned(
              top: 150,
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _serverUsers.length,
                itemBuilder: (context, index) {
                  final user = _serverUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildUserAvatar(user.name, user.photoUrl, Colors.greenAccent),
                  );
                },
              ),
            ),

            // BLE Devices (Blue)
            Positioned(
              bottom: 150,
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bleDevices.length,
                itemBuilder: (context, index) {
                  final device = _bleDevices[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildUserAvatar(
                      device.device.platformName.isEmpty
                          ? "Unknown ID"
                          : device.device.platformName,
                      "https://ui-avatars.com/api/?name=B&background=0D8ABC&color=fff",
                      Colors.blueAccent,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isScanning ? Colors.red : Colors.green,
        onPressed: () => setState(() => _isScanning = !_isScanning),
        child: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Widget _buildUserAvatar(String name, String url, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 20)],
          ),
          child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(url)),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(15)),
          child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }
}
