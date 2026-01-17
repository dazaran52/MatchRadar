import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // 👈 BLE
import 'api_service.dart';
import 'ble_service.dart'; // 👈 Наш сервис

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
  final BleService _ble = BleService(); // 👈
  
  List<User> _serverUsers = [];
  List<ScanResult> _bleDevices = []; // 👈 Найденные по Bluetooth
  
  bool _isScanning = true;
  Timer? _timer;
  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initRadar();
  }

  void _initRadar() async {
    // 1. Запускаем BLE
    bool bleReady = await _ble.init();
    if (bleReady) {
      _ble.startScan();
      // Слушаем эфир
      _ble.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _bleDevices = results;
          });
        }
      });
    }

    // 2. Запускаем цикл GPS
    _startGpsCycle();
  }

  void _startGpsCycle() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isScanning) return;
      try {
        Position position = await _determinePosition();
        setState(() => _statusMessage = "GPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}");
        
        final users = await _api.scanRadar(1, position.latitude, position.longitude);
        if (mounted) setState(() => _serverUsers = users);
        
        // Перезапускаем скан BLE каждые 5 секунд, чтобы список был свежим
        if (!timer.tick.isEven) { 
           _ble.stopScan();
           _ble.startScan();
        }

      } catch (e) {
        print("Error: $e");
      }
    });
  }

  Future<Position> _determinePosition() async {
    // (Код GPS остался тем же, сократил для краткости)
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
    // Объединяем списки: Серверные юзеры + BLE устройства
    int totalFound = _serverUsers.length + _bleDevices.length;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
             // Радар (круги)
            if (_isScanning)
            ...List.generate(3, (index) {
              return Container(
                width: 300, height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2)),
              ).animate(onPlay: (c) => c.repeat()).scale(duration: 2.seconds, delay: (index * 600).ms, begin: const Offset(0.1, 0.1), end: const Offset(1.5, 1.5)).fadeOut(duration: 2.seconds, delay: (index * 600).ms);
            }),

            const Icon(Icons.location_on, color: Colors.white, size: 50),

            Positioned(
              top: 50,
              child: Column(
                children: [
                  Text(_statusMessage, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text("Found: $totalFound", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (_bleDevices.isNotEmpty) 
                    Text("(${_bleDevices.length} via Bluetooth)", style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                ],
              ),
            ),

            // 1. Отрисовка пользователей с СЕРВЕРА (Зеленые)
            ..._serverUsers.map((user) {
              return Positioned(
                top: 150,
                child: _buildUserAvatar(user.name, user.photoUrl, Colors.greenAccent),
              );
            }),

            // 2. Отрисовка BLUETOOTH устройств (Синие)
            // Смещаем их чуть ниже, чтобы не накладывались
            ..._bleDevices.map((device) {
              return Positioned(
                bottom: 150, 
                child: _buildUserAvatar(
                  device.device.platformName.isEmpty ? "Unknown ID" : device.device.platformName, 
                  "https://ui-avatars.com/api/?name=B&background=0D8ABC&color=fff", // Заглушка аватарки
                  Colors.blueAccent
                ),
              );
            }),
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
