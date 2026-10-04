import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// Cinematic Editorial Photography Theme for FrameFolio.
/// Palette: Near-Black #0B0C0D | Surface #17191B | Off-White Text #F5F3EE | Subtle Champagne #C8A97E
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(AppConstants.primaryColor),
    brightness: Brightness.dark,
    surface: const Color(AppConstants.cardColorValue),
    primary: const Color(AppConstants.primaryColor),
    secondary: const Color(AppConstants.accentColor),
    onPrimary: const Color(AppConstants.backgroundColorValue),
    onSurface: const Color(AppConstants.textPrimaryValue),
  ),
  scaffoldBackgroundColor: const Color(AppConstants.backgroundColorValue),

  // AppBar — Dark Near-Black background, Warm Off-White title
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: const Color(AppConstants.backgroundColorValue),
    foregroundColor: const Color(AppConstants.textPrimaryValue),
    centerTitle: false,
    titleTextStyle: GoogleFonts.playfairDisplay(
      color: const Color(AppConstants.textPrimaryValue),
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(
      color: Color(AppConstants.textPrimaryValue),
    ),
  ),

  // Cards — Dark #17191B surface with subtle #303133 border
  cardTheme: CardThemeData(
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.6),
    color: const Color(AppConstants.cardColorValue),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: Color(AppConstants.surfaceBorderValue),
        width: 1,
      ),
    ),
    margin: EdgeInsets.zero,
  ),

  // Input fields — Dark #17191B fill, #303133 border, #C8A97E focus border
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(AppConstants.cardColorValue),
    hintStyle: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textMutedValue),
      fontSize: 14,
    ),
    labelStyle: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textSecondaryValue),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    prefixIconColor: const Color(AppConstants.textSecondaryValue),
    suffixIconColor: const Color(AppConstants.textSecondaryValue),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(AppConstants.surfaceBorderValue),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(AppConstants.surfaceBorderValue),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(AppConstants.primaryColor),
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),

  // Primary ElevatedButton — Off-White #F5F3EE fill with Near-Black #0B0C0D text
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(AppConstants.textPrimaryValue),
      foregroundColor: const Color(AppConstants.backgroundColorValue),
      minimumSize: const Size.fromHeight(52),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    ),
  ),

  // OutlinedButton — Border #303133 with Off-White #F5F3EE text
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(AppConstants.textPrimaryValue),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(
        color: Color(AppConstants.surfaceBorderValue),
        width: 1.5,
      ),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  // TextButton — Warm Champagne accent
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(AppConstants.primaryColor),
      textStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  ),

  // Typography — Editorial Serif (Playfair Display) + Modern Sans-Serif (Plus Jakarta Sans)
  textTheme: TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      color: const Color(AppConstants.textPrimaryValue),
      fontWeight: FontWeight.bold,
      fontSize: 36,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      color: const Color(AppConstants.textPrimaryValue),
      fontWeight: FontWeight.bold,
      fontSize: 28,
      letterSpacing: 0.2,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      color: const Color(AppConstants.textPrimaryValue),
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textPrimaryValue),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textPrimaryValue),
      fontWeight: FontWeight.w600,
      fontSize: 15,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textPrimaryValue),
      fontSize: 15,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textSecondaryValue),
      fontSize: 14,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textMutedValue),
      fontSize: 12,
    ),
  ),

  // Chip theme — Dark surface with subtle borders
  chipTheme: ChipThemeData(
    backgroundColor: const Color(AppConstants.cardColorValue),
    selectedColor: const Color(AppConstants.textPrimaryValue),
    disabledColor: Colors.grey.shade900,
    labelStyle: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.textSecondaryValue),
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    secondaryLabelStyle: GoogleFonts.plusJakartaSans(
      color: const Color(AppConstants.backgroundColorValue),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    side: const BorderSide(color: Color(AppConstants.surfaceBorderValue)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  ),

  // Dialog Theme — Dark Elevated Card surface #1D1F21
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(AppConstants.cardElevatedValue),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(AppConstants.surfaceBorderValue)),
    ),
  ),
);
