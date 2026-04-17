// Ficheiro: lib/core/theme/app_theme.dart

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
        primary: Color(0xFFFFB300), 
        secondary: Color(0xFF00E676), 
        surface: Color(0xFF121212), 
        surfaceContainerHighest: Color(0xFF1E1E1E), 
        error: Color(0xFFFF5252),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      // CORREÇÃO: Utilização de CardThemeData em vez de CardTheme
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          // Utilização de BorderRadius.all para permitir o const
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),
      
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFFB3B3B3)),
      ),
      
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2C2C2C),
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: const Color(0xFFFFB300).withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: Color(0xFFFFB300));
          return const IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold);
          return const TextStyle(color: Colors.grey);
        }),
      ),
    );
  }
}