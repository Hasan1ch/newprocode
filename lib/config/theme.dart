import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

// Central theme configuration for the entire app
// Manages both light and dark themes with consistent styling
class AppTheme {
  // Quick access color getters for legacy code compatibility
  // These map to our centralized color definitions
  static Color get cardColor => AppColors.surfaceDark;
  static Color get primaryColor => AppColors.primary;
  static Color get backgroundColor => AppColors.backgroundDark;
  static Color get surface => AppColors.surfaceDark;
  static Color get background => AppColors.backgroundDark;
  static Color get text => AppColors.textLight;
  static Color get textSecondary => AppColors.textGrey;
  static Color get primary => AppColors.primary;
  static Color get secondary => AppColors.secondary;
  static Color get success => AppColors.success;
  static Color get error => AppColors.error;
  static Color get warning => AppColors.warning;
  static Color get accent => AppColors.secondary;
  static Color get border => AppColors.divider;
  static Color get textPrimary => AppColors.textLight;

  // Primary gradient for buttons and highlights
  // Creates a smooth transition from lighter to darker purple
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient for accent elements
  // Used for special cards and achievement displays
  static const LinearGradient accentGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme configuration for daytime use
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'Poppins', // Modern, clean font for readability
    useMaterial3: true, // Latest Material Design guidelines

    // Color palette for light mode
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white, // Text on primary color
      onSecondary: Colors.white, // Text on secondary color
      onSurface: AppColors.textDark, // Text on surface elements
      onError: Colors.white, // Text on error color
      outline: AppColors.divider, // Border and divider color
      surfaceContainerHighest: Color(0xFFE7E0EC), // Elevated surfaces
      onSurfaceVariant: AppColors.textGrey, // Secondary text
    ),

    // Top navigation bar styling
    appBarTheme: const AppBarTheme(
      elevation: 0, // Flat design, no shadow
      centerTitle: true, // Title always centered
      backgroundColor: Colors.transparent, // Blends with background
      iconTheme: IconThemeData(color: AppColors.textDark),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),

    // Typography system following Material Design hierarchy
    textTheme: const TextTheme(
      // Large display text for hero sections
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        letterSpacing: -0.5, // Tighter spacing for large text
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),

      // Section headers and titles
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),

      // Card titles and list items
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),

      // Main content text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textGrey, // Subtle for less important text
      ),

      // Button and form labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      ),
    ),

    // Card design with subtle shadow - FIXED: Changed from CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: 2, // Subtle shadow
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // Rounded corners
      color: AppColors.surfaceLight,
    ),

    // Primary action button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Flat design
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Text-only button styling
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Outlined button for secondary actions
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Text field styling for forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // Background fill
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: AppColors.primary, width: 2), // Highlight when focused
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
    ),

    // Bottom navigation styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textGrey,
      type: BottomNavigationBarType.fixed, // All items visible
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Filter and selection chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      disabledColor: AppColors.surfaceLight.withValues(alpha: 0.5),
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: const TextStyle(
        color: AppColors.textDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.light,
    ),

    // Modal dialog styling - FIXED: Changed from DialogTheme to DialogThemeData
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: AppColors.surfaceLight,
    ),

    // Bottom sheet for actions
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Divider lines between content
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
  );

  // Dark theme configuration for night mode
  // Mirrors light theme structure with appropriate dark colors
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'Poppins',
    useMaterial3: true,

    // Dark mode color palette
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textLight,
      onError: Colors.white,
      outline: Color(0xFF49454F), // Subtle borders in dark mode
      surfaceContainerHighest: Color(0xFF49454F),
      onSurfaceVariant: Color(0xFFCAC4D0),
    ),

    // Dark mode app bar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.textLight),
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),

    // Dark mode typography - same sizes, different colors
    textTheme: const TextTheme(
      // Display styles for dark mode
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),

      // Headlines for dark mode
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),

      // Titles for dark mode
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),

      // Body text for dark mode
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textLight,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textGrey,
      ),

      // Labels for dark mode
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      ),
    ),

    // Dark mode card styling - FIXED: Changed from CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surfaceDark,
    ),

    // Buttons maintain same style in dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Text button for dark mode
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Outlined button for dark mode
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Dark mode input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      hintStyle: TextStyle(
        color: AppColors.textGrey.withValues(alpha: 0.7), // Dimmer hints
        fontSize: 14,
      ),
    ),

    // Dark mode bottom navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Dark mode chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceDark,
      disabledColor: AppColors.surfaceDark.withValues(alpha: 0.5),
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.dark,
    ),

    // Dark mode dialogs - FIXED: Changed from DialogTheme to DialogThemeData
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: AppColors.surfaceDark,
    ),

    // Dark mode bottom sheets
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Subtle dividers for dark mode
    dividerTheme: DividerThemeData(
      color: AppColors.divider
          .withValues(alpha: 0.3), // More transparent in dark mode
      thickness: 1,
      space: 1,
    ),
  );
}
