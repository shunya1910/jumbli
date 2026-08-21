import 'package:flutter/material.dart';

class AppColors {
  // Primary Palettes (Playful and Premium)
  static const Color primary = Color(0xFF6B4EE6); // Deep playful purple
  static const Color primaryLight = Color(0xFF9078EB);

  static const Color secondary = Color(0xFFFF6B6B); // Soft energetic red/pink
  static const Color secondaryLight = Color(0xFFFF8E8E);

  static const Color accent = Color(0xFFFFD93D); // Cheerful yellow
  static const Color success = Color(0xFF4ADE80); // Vibrant green

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Colors.white;

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B4EE6), Color(0xFF9078EB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
  );
}
