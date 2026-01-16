import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'api_service.dart';

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
  List<User> _nearbyUsers = [];
  bool _isScanning = true;
  Timer? _timer;

  final double myLat = 50.0750;
  final double myLng = 14.4370;

  @override
  void initState() {
    super.initState();
    _startRadar();
  }

  void _startRadar() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isScanning) return;
      print("📡 Radar Ping...");
      final users = await _api.scanRadar(1, myLat, myLng);
      if (mounted) {
        setState(() {
          _nearbyUsers = users;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👇 1. Добавили SizedBox.expand, чтобы радар был на весь экран
      body: SizedBox.expand( 
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isScanning)
            ...List.generate(3, (index) {
              return Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(duration: 2.seconds, delay: (index * 600).ms, begin: const Offset(0.1, 0.1), end: const Offset(1.5, 1.5))
              .fadeOut(duration: 2.seconds, delay: (index * 600).ms);
            }),

            // 👇 2. Поменяли иконку, а то "стрелочка" визуально кажется кривой
            const Icon(Icons.location_on, color: Colors.white, size: 50),

            Positioned(
              top: 50,
              child: Text(
                _nearbyUsers.isEmpty ? "Scanning..." : "Found: ${_nearbyUsers.length}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ..._nearbyUsers.map((user) {
              return Positioned(
                top: 150, 
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.greenAccent, width: 3),
                        boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 20)],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "${user.name} \n📍 ~100m", 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
}
