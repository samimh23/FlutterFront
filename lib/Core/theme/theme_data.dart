import 'package:flutter/material.dart';

// Light theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  navigationDrawerTheme: const NavigationDrawerThemeData(
    backgroundColor: Colors.white,
    indicatorColor: Colors.green,
  ),
  iconTheme: const IconThemeData(
    color: Colors.green,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    bodyMedium: TextStyle(
      color: Colors.black87,
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.green,
    secondary: Colors.green.shade700,
  ),
);

// Dark theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.green,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[850],
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: Colors.grey[800],
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  navigationDrawerTheme: NavigationDrawerThemeData(
    backgroundColor: Colors.grey[850],
    indicatorColor: Colors.green,
  ),
  iconTheme: const IconThemeData(
    color: Colors.green,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    bodyMedium: TextStyle(
      color: Colors.white70,
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.green,
    secondary: Colors.green.shade300,
  ),
);