import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color emeraldGreen = Color(0xFF096A4B);
  static const Color forestGreen = Color(0xFF07543A);
  static const Color lightGreen = Color(0xFFE8F0ED); // For unselected tabs, etc.
  
  // Neutral Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFF6F9F7);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF2E3D36);
  static const Color textSecondaryLight = Color(0xFF7A8A82);
  static const Color borderLight = Color(0xFFE2EBE6);
  static const Color iconLight = Color(0xFF4A5C54);

  // Neutral Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF121413);
  static const Color cardDark = Color(0xFF1E211F);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);
  static const Color borderDark = Color(0xFF2C332F);
  static const Color iconDark = Color(0xFFB0B0B0);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Premium Gradients
  static const List<Color> offlineGradient = [Color(0xFFE53935), Color(0xFFB71C1C)];
  static const List<Color> onlineGradient = [Color(0xFF4CAF50), Color(0xFF1B5E20)];
  static const List<Color> glassGradient = [Color(0xFF096A4B), Color(0xFF07543A)];
  static const List<Color> shimmerGradient = [Color(0xFFE8F0ED), Color(0xFFD0E4DA), Color(0xFFE8F0ED)];

  // Glass / Frost
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC1E211F);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
}
