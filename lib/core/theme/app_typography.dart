import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getLightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ), // Buttons
    );
  }
}
