import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String THEME_KEY = 'theme_key';
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  ThemeProvider() {
    // Initialize theme from preferences when created
    initializeTheme();
  }

  ThemeMode get themeMode => _themeMode;

  // Method to initialize theme from shared preferences
  Future<void> initializeTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int themeIndex = prefs.getInt(THEME_KEY) ?? 0; // Default to dark (0)
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // Fallback to dark mode if there's an error
      _themeMode = ThemeMode.dark;
      print('Error initializing theme: $e');
    }
  }

  // Toggle theme and save preference
  void toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    
    // Notify listeners immediately for UI update
    notifyListeners();
    
    // Save to SharedPreferences
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(THEME_KEY, _themeMode.index);
      print('Theme saved: ${_themeMode.toString()}');
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}