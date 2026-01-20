import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonTheme {
  static const Color bgTop = Color(0xFF090014);
  static const Color bgBottom = Color(0xFF1A0B3C);
  static const Color cyberCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFD900FF);
  static final Color glassSurface = Colors.white.withOpacity(0.05);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgTop, // Will be overridden by Container gradient
      primaryColor: cyberCyan,
      colorScheme: ColorScheme.dark(
        primary: cyberCyan,
        secondary: neonMagenta,
        surface: glassSurface,
        background: bgTop,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: cyberCyan,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 18,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          color: Colors.white60,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black12,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cyberCyan, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
        hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
      ),
    );
  }

  static BoxDecoration get backgroundGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [bgTop, bgBottom],
    ),
  );
}
