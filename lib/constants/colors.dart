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
  static const Color buttonShadowMedium = Color(0x17000000);
  static const Color buttonShadowLight = Color(0x0D000000);
  static const Color buttonShadowExtraLight = Color(0x03000000);
  static const Color shadowTransparent = Color(0x00000000);

  // Nav Item Colors (from existing design)
  static const Color navGradientStart = Color(0x24D6D6D6);
  static const Color navGradientEnd = Color(0x23707070);
  static const Color navGradientStartActive = Color(0x66D6D6D6);
  static const Color navGradientEndActive = Color(0x66707070);
  static const Color navBorderActive = Color(0x80F2F2F2);
  static const Color navBorderInactive = Color(0x00000000);
  static const Color navTextActive = Color(0xFFFFFFFF); // #FFFFFF
  static const Color navTextInactive = Color(0x66FFFFFF); // #FFFFFF66

  // Input Field Colors
  static const Color inputGradientStart = Color(0x33D6D6D6); // rgba(214,214,214,0.2)
  static const Color inputGradientEnd = Color(0x33707070); // rgba(112,112,112,0.2)
  static const Color inputShadow = Color(0x40000000); // #00000040

  // Login Screen Colors
  static const Color scaffoldDark = Color(0xFF181B20);
  static const Color linkBlue = Color(0xFF68AEFF);
  static const Color buttonGrey = Color(0xFF707070);
  static const Color buttonShadow = Color(0x1A000000);
  static const Color bottomNavBackground = Color(0xFF0D0D0E);

  // Utility
  static const Color transparent = Color(0x00000000);
}

