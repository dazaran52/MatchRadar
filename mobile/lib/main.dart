import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart'; // 👈 Добавили библиотеку GPS
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
  
  // Больше никаких хардкодных координат!
  String _statusMessage = "Initializing GPS..."; 

  @override
  void initState() {
    super.initState();
    _startRadar();
  }

  // 🔥 Магия получения координат
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Проверяем, включен ли GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // 2. Проверяем разрешения
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // 3. Возвращаем текущую позицию
    return await Geolocator.getCurrentPosition();
  }

  void _startRadar() {
    // Сканируем каждые 3 секунды
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!_isScanning) return;

      try {
        // 👇 Получаем РЕАЛЬНЫЕ координаты
        Position position = await _determinePosition();
        
        setState(() {
          _statusMessage = "Scanning at \n${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        });

        // Отправляем их на сервер
        print("📡 Ping Server: ${position.latitude}, ${position.longitude}");
        final users = await _api.scanRadar(1, position.latitude, position.longitude);
        
        if (mounted) {
          setState(() {
            _nearbyUsers = users;
          });
        }
      } catch (e) {
        print("❌ GPS Error: $e");
        if (mounted) {
           setState(() => _statusMessage = "GPS Error: $e");
        }
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
      body: SizedBox.expand( 
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Анимация радара
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

            const Icon(Icons.location_on, color: Colors.white, size: 50),

            // Статус вверху
            Positioned(
              top: 50,
              child: Text(
                _nearbyUsers.isEmpty ? _statusMessage : "Found: ${_nearbyUsers.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),

            // Найденные пользователи
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
                        "${user.name} \n📍 Nearby", 
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
