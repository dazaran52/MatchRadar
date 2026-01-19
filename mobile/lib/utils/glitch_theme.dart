import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlitchTheme {
  static const Color neonRed = Color(0xFFFF003C);
  static const Color neonCyan = Color(0xFF00F0FF); // Cyberpunk Cyan
  static const Color neonGreen = Color(0xFF00FF00); // CRT Green
  static const Color darkBg = Color(0xFF050505);
  static const Color gridLine = Color(0xFF1A1A1A);

  static TextStyle get terminalStyle => GoogleFonts.shareTechMono(
    color: neonGreen,
    fontSize: 14,
  );

  static TextStyle get headerStyle => GoogleFonts.audiowide(
    color: neonRed,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get dataStyle => GoogleFonts.firaCode(
    color: neonCyan,
    fontSize: 12,
  );

  static ThemeData get themeData => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBg,
    primaryColor: neonRed,
    colorScheme: const ColorScheme.dark(
      primary: neonRed,
      secondary: neonCyan,
      surface: Color(0xFF121212),
    ),
    textTheme: TextTheme(
      bodyMedium: terminalStyle,
      titleLarge: headerStyle,
    ),
  );
}
