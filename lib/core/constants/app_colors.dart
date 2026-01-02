import 'package:flutter/material.dart';

class AppColors {
  // === DARK NEUTRAL BASE ===
  static const Color black = Color(0xFF000000);
  static const Color darkestGray = Color(0xFF0A0A0A);
  static const Color darkerGray = Color(0xFF121212);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color mediumGray = Color(0xFF242424);
  static const Color lightGray = Color(0xFF2D2D2D);
  static const Color lighterGray = Color(0xFF3A3A3A);
  static const Color lightestGray = Color(0xFF4A4A4A);
  static const Color primaryDark = Color(0xFF0F1115);
  static const Color secondaryDark = Color(0xFF1A1D24);


  static const Color white = Colors.white;
  // === NEON ACCENTS ===
  static const Color neonYellow = Color(0xFFFFD700);
  static const Color neonAmber = Color(0xFFFFC107);
  static const Color neonOrange = Color(0xFFFF9800);
  static const Color neonRed = Color(0xFFF44336);
  static const Color neonBlue = Color(0xFF2196F3);
  static const Color neonGreen = Color(0xFF4CAF50);
  static const Color neonPurple = Color(0xFF9C27B0);

  // === DETECTIVE SPECIFIC ===
  static const Color crimeTapeYellow = Color(0xFFFFEB3B);
  static const Color evidenceRed = Color(0xFFD32F2F);
  static const Color clueBlue = Color(0xFF1976D2);
  static const Color fingerprintBrown = Color(0xFF5D4037);
  static const Color parchment = Color(0xFFF5E6CA);
  static const Color bloodRed = Color(0xFFB71C1C);
  static const Color policeBlue = Color(0xFF0D47A1);

  // === TEXT COLORS ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF616161);

  // === UI STATES ===
  static const Color success = neonGreen;
  static const Color error = neonRed;
  static const Color warning = neonOrange;
  static const Color info = neonBlue;

  // === SHADOWS & OVERLAYS ===
  static const Color shadow = Color(0x40000000);
  static const Color overlay = Color(0x80000000);

  // === GRADIENTS ===
  static LinearGradient get detectiveGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [darkerGray, black],
    );
  }

  static LinearGradient get neonGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [neonYellow, neonOrange],
    );
  }

  static LinearGradient get cardGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [darkGray, darkerGray],
    );
  }
}