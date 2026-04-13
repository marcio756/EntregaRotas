import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provides the centralized design system for the application.
/// We default to a Dark Mode primary experience to save battery and reduce 
/// eye strain during early morning delivery routes.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF64FFDA),
        secondary: Color(0xFF00BFA5),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFFF5252),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF333333),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}