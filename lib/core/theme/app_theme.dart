import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Material 3 theme – minimal, image-forward photography aesthetic.
/// Palette: Background #F7F5F0 | Cards #FFFFFF | Primary #222222 | Accent #A67C52
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(AppConstants.accentColor),
    brightness: Brightness.light,
    surface: const Color(AppConstants.cardColorValue),
    primary: const Color(AppConstants.primaryColor),
  ).copyWith(
    primary: const Color(AppConstants.primaryColor),
    secondary: const Color(AppConstants.accentColor),
    surface: const Color(AppConstants.cardColorValue),
    onPrimary: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(AppConstants.backgroundColorValue),

  // AppBar — flat white, dark text, no elevation
  appBarTheme: const AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(AppConstants.cardColorValue),
    foregroundColor: Color(AppConstants.primaryColor),
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Color(AppConstants.primaryColor),
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
    ),
  ),

  // Cards — white, subtle shadow, 16 px radius
  cardTheme: CardThemeData(
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    color: const Color(AppConstants.cardColorValue),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: EdgeInsets.zero,
  ),

  // Input fields — light fill, no border, rounded
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(AppConstants.accentColor),
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: const TextStyle(color: Colors.grey),
  ),

  // Primary ElevatedButton — dark/charcoal
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(AppConstants.primaryColor),
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),

  // OutlinedButton — accent border
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(AppConstants.primaryColor),
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(color: Color(AppConstants.primaryColor), width: 1.5),
    ),
  ),

  // TextButton
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(AppConstants.accentColor),
    ),
  ),

  // Typography
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: Color(AppConstants.primaryColor),
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Color(AppConstants.primaryColor),
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Color(AppConstants.primaryColor),
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(color: Color(AppConstants.primaryColor)),
    bodyMedium: TextStyle(color: Colors.black87),
  ),

  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF0EBE3),
    labelStyle: const TextStyle(
      color: Color(AppConstants.accentColor),
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),
);
