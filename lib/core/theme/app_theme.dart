import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkDetectiveTheme {
    return ThemeData.dark().copyWith(
      // === SCAFFOLD & BACKGROUNDS ===
      scaffoldBackgroundColor: AppColors.darkerGray,
      canvasColor: AppColors.darkGray,
      cardColor: AppColors.mediumGray,

      // === COLOR SCHEME ===
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonYellow,
        secondary: AppColors.neonOrange,
        surface: AppColors.darkGray,
        background: AppColors.darkerGray,
        error: AppColors.neonRed,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),

      // === DIALOG THEME (FIXED) ===
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // === APP BAR ===
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkestGray,
        elevation: 4,
        shadowColor: AppColors.shadow,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.neonYellow),
        titleTextStyle: TextStyle(
          color: AppColors.neonYellow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier New',
          letterSpacing: 1.5,
        ),
      ),

      // === INPUT FIELDS ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mediumGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        errorStyle: const TextStyle(color: AppColors.neonRed),
        floatingLabelStyle: const TextStyle(color: AppColors.neonYellow),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lighterGray),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.neonYellow,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonRed),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.neonRed,
            width: 2,
          ),
        ),
      ),

      // === BUTTONS ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonYellow,
          foregroundColor: AppColors.black,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          elevation: 4,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonYellow,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // === CARD THEME (FIXED) ===
      cardTheme: CardThemeData(
        color: AppColors.darkGray,
        elevation: 4,
        shadowColor: AppColors.shadow,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // === TEXT THEME ===
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),

      // === ICON THEME ===
      iconTheme: const IconThemeData(
        color: AppColors.neonYellow,
      ),
    );
  }
}
