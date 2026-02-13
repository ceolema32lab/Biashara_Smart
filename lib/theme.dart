import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryTech = Color(0xFF6366F1); // Indigo
  static const Color slateBg = Color(0xFF0F172A);    // Deep Dark

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: slateBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryTech,
      surface: Color(0xFF1E293B),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryTech,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  );
}