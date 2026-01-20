import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonTheme {
  // Screenshot inspired colors
  static const Color bgTop = Color(0xFF140034); // Deep Purple
  static const Color bgBottom = Color(0xFF5B1DA3); // Lighter Violet

  static const Color cyberCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFD900FF);
  static const Color neonGreen = Color(0xFF00FF9D);
  static const Color neonRed = Color(0xFFFF003C);

  static final Color glassSurface = Colors.white.withOpacity(0.1); // Slightly clearer glass

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgTop,
      primaryColor: neonMagenta,
      colorScheme: ColorScheme.dark(
        primary: neonMagenta,
        secondary: cyberCyan,
        surface: glassSurface,
        background: bgTop,
        error: neonRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 3.0,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: neonMagenta.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
           borderSide: BorderSide(color: neonRed, width: 1),
           borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
           borderSide: BorderSide(color: neonRed, width: 2),
           borderRadius: BorderRadius.circular(16),
        ),
        labelStyle: GoogleFonts.rajdhani(color: Colors.white70),
        hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }

  static BoxDecoration get backgroundGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [bgTop, bgBottom],
    ),
  );

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple to Deep Blue/Purple
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient get buttonGradient => const LinearGradient(
    colors: [Color(0xFFB030FF), Color(0xFF6B11FF)], // Lighter Purple to Darker Purple
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
