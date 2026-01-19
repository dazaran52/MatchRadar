import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/screens/radar_screen.dart';
import 'utils/glitch_theme.dart';

void main() {
  // Делаем статус-бар прозрачным для полного погружения
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const GlitchApp());
}

class GlitchApp extends StatelessWidget {
  const GlitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glitch',
      debugShowCheckedModeBanner: false,
      // Подключаем новую тему, если она есть, или ставим темную по дефолту
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      // 👇 Вот он, наш новый экран!
      home: const RadarScreen(),
    );
  }
}
