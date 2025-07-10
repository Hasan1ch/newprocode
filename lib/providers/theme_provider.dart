import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider managing app theme preferences
/// Persists theme choice across app sessions using SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  // Theme state
  ThemeMode _themeMode = ThemeMode.system;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Getters for UI binding
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  // Check if currently in dark mode
  // Considers both explicit dark mode and system dark mode
  bool get isDarkMode =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark);

  // Initialize theme from storage
  // Loads saved theme preference on app startup
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      final savedTheme = _prefs.getString(_themeKey);

      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize theme: $e');
    }
  }

  // Set theme mode
  // Updates theme and persists choice to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Save to storage
    try {
      await _prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  // Toggle between light and dark
  // Smart toggle that respects system theme when applicable
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system theme, toggle to opposite of current system theme
      final isDark =
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
      await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  // Get theme display name
  // Returns user-friendly name for settings UI
  String getThemeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get icon for current theme
  // Returns appropriate icon for theme selector UI
  IconData getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
