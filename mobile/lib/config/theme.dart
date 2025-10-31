import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1E40AF);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentGold = Color(0xFFF59E0B);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, height: 1.5),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, height: 1.5),
      bodySmall: GoogleFonts.roboto(fontSize: 12, height: 1.4),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: const Color(0xFF1E293B),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF1F5F9),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: const Color(0xFFF1F5F9),
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: const Color(0xFFF1F5F9),
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        height: 1.5,
        color: const Color(0xFFF1F5F9),
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        height: 1.5,
        color: const Color(0xFF94A3B8),
      ),
    ),
  );
}
