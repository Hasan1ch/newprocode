import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryDark = Color(0xFF4F378B);
  static const Color primaryLight = Color(0xFF7D5DC6);

  // Secondary Colors
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryDark = Color(0xFF4A4458);
  static const Color secondaryLight = Color(0xFF7A7289);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF1C1B1F);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2B2930);

  // Card Color (for dark theme)
  static const Color surface = surfaceDark;

  // Text Colors
  static const Color textDark = Color(0xFF1C1B1F);
  static const Color textLight = Color(0xFFE6E1E5);
  static const Color textGrey = Color(0xFF79747E);
  static const Color textPrimary = textLight; // Alias for dark theme
  static const Color textSecondary = textGrey; // Alias for consistency

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Other Colors
  static const Color divider = Color(0xFFCAC4D0);

  // Additional colors that might be needed
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Grey shades
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    primary,
    primaryLight,
  ];

  static const List<Color> secondaryGradient = [
    secondary,
    secondaryLight,
  ];

  static const List<Color> successGradient = [
    success,
    Color(0xFF66BB6A),
  ];

  static const List<Color> errorGradient = [
    error,
    Color(0xFFE53935),
  ];
}
