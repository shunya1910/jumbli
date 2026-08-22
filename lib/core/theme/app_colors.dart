import 'package:flutter/material.dart';

class AppColors {
  // Primary Palettes (Modern & Premium)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);

  static const Color secondary = Color(0xFFF43F5E); // Rose
  static const Color secondaryLight = Color(0xFFFB7185);

  static const Color accent = Color(0xFF14B8A6); // Teal
  static const Color success = Color(0xFF10B981); // Emerald

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceLight = Colors.white;

  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
  );
}
