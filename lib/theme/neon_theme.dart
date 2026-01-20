import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonTheme {
  static const Color bgTop = Color(0xFF090014);
  static const Color bgBottom = Color(0xFF1A0B3C);
  static const Color cyberCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFD900FF);
  static const Color neonGreen = Color(0xFF00FF9D); // Success/Match
  static const Color neonRed = Color(0xFFFF003C);   // Reject/Error

  static final Color glassSurface = Colors.white.withOpacity(0.05);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgTop,
      primaryColor: cyberCyan,
      colorScheme: ColorScheme.dark(
        primary: cyberCyan,
        secondary: neonMagenta,
        surface: glassSurface,
        background: bgTop,
        error: neonRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: cyberCyan,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: neonMagenta,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.orbitron(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black12,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cyberCyan, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
           borderSide: BorderSide(color: neonRed, width: 1),
           borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
           borderSide: BorderSide(color: neonRed, width: 2),
           borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
        hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [cyberCyan, neonMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
