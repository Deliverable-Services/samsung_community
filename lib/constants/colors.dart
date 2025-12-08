import 'package:flutter/material.dart';

/// App color palette
/// Define all project colors here for consistency and easy maintenance
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFD6D6D6);
  static const Color greyDark = Color(0xFF707070);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Shadow Colors
  static const Color shadow = Color(0x33000000);

  // Nav Item Colors (from existing design)
  static const Color navGradientStart = Color(0x24D6D6D6);
  static const Color navGradientEnd = Color(0x23707070);
  static const Color navGradientStartActive = Color(0x66D6D6D6);
  static const Color navGradientEndActive = Color(0x66707070);
  static const Color navBorderActive = Color(0x80F2F2F2);
  static const Color navBorderInactive = Color(0x00000000);
}

