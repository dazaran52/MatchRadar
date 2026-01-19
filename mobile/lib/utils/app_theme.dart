import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryPurple = Color(0xFF8E2DE2);
  static const Color primaryPink = Color(0xFF4A00E0);

  static const Color midnightBlue = Color(0xFF0F0C29);
  static const Color deepPurple = Color(0xFF302B63);
  static const Color almostBlack = Color(0xFF24243E);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB3B3B3);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [midnightBlue, deepPurple, almostBlack],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static TextStyle get titleStyle => GoogleFonts.poppins(
    color: textWhite,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyStyle => GoogleFonts.inter(
    color: textGrey,
    fontSize: 14,
  );

  static TextStyle get cardTitle => GoogleFonts.poppins(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get cardSubtitle => GoogleFonts.inter(
    color: Colors.black54,
    fontSize: 12,
  );

  static ThemeData get themeData => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: midnightBlue, // Fallback
    primaryColor: primaryPurple,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryPink,
      surface: Colors.white,
    ),
    textTheme: TextTheme(
      bodyMedium: bodyStyle,
      titleLarge: titleStyle,
    ),
  );
}
