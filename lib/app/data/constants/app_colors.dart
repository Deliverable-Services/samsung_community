import 'package:flutter/material.dart';

/// App color palette
/// Define all project colors here for consistency and easy maintenance
class AppColors {
  AppColors._();

  // Primary Colors
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
  static const Color inputGradientStart = Color(
    0x33D6D6D6,
  ); // rgba(214,214,214,0.2)
  static const Color inputGradientEnd = Color(
    0x33707070,
  ); // rgba(112,112,112,0.2)
  static const Color inputShadow = Color(0x40000000); // #00000040

  // Login Screen Colors
  static const Color primary = Color(0xFF181B20);
  static const Color linkBlue = Color(0xFF68AEFF); // Used in login/auth screens
  static const Color buttonGrey = Color(0xFF707070);
  static const Color buttonShadow = Color(0x1A000000);
  static const Color bottomNavBackground = Color(0xFF0D0D0E);

  // Welcome Screen Colors
  static const Color welcomeGradientStart = Color.fromRGBO(214, 214, 214, 0.1);
  static const Color welcomeGradientEnd = Color.fromRGBO(112, 112, 112, 0.1);
  static const Color welcomeContainerShadow = Color(0x1A000000); // #0000001A

  // Overlay Colors
  static const Color overlayBackground = Color(0xC2151618); // #151618C2
  static const Color overlayContainerBackground = Color(0xFF292E36); // #292E36
  static const Color overlayContainerShadow = Color(0x4D000000); // #0000004D
  static const Color optionBoxShadow = Color(0x1A000000); // #0000001A
  static const Color optionTextGradientStart = Color(0xFFBEBEBE); // #BEBEBE
  static const Color optionTextGradientEnd = Color(0xFFFFFFFF); // #FFFFFF
  static const Color backButtonInsetShadow = Color(0x40000000); // #00000040
  static const Color uploadImageBackground = Color(0xFF35383C); // #35383C
  static const Color uploadImageShadow = Color(0x40000000); // #00000040

  // Utility
  static const Color transparent = Color(0x00000000);

  // Card & Container Colors
  static const Color cardGradientStart = Color.fromRGBO(214, 214, 214, 0.14);
  static const Color cardGradientEnd = Color.fromRGBO(112, 112, 112, 0.14);
  static const Color cardShadow = Color(0x1A000000); // #0000001A

  // Button & Icon Gradient Colors
  static const Color buttonGradientStart = Color.fromRGBO(214, 214, 214, 0.2);
  static const Color buttonGradientEnd = Color.fromRGBO(112, 112, 112, 0.2);
  static const Color buttonGradientStartLight = Color.fromRGBO(
    214,
    214,
    214,
    0.1,
  );
  static const Color buttonGradientEndLight = Color.fromRGBO(
    112,
    112,
    112,
    0.1,
  );
  static const Color buttonGradientStartMedium = Color.fromRGBO(
    214,
    214,
    214,
    0.4,
  );
  static const Color buttonGradientEndMedium = Color.fromRGBO(
    112,
    112,
    112,
    0.4,
  );

  // Accent Colors (Primary Blue)
  static const Color accentBlue = Color(0xFF20AEFE); // Primary accent blue
  static const Color accentBlueDark = Color(0xFF135FFF); // Darker blue variant
  static const Color accentBlueLight = Color(
    0xFF8CB5FF,
  ); // Light blue for sliders

  // Background Colors
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color backgroundDarkMedium = Color(0xFF2A2A2A);
  static const Color backgroundGrey = Color(0xFF4A4A4A);

  // Text Colors with Opacity
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhiteSecondary = Color(0xFFBDBDBD);
  static const Color textWhiteOpacity60 = Color(
    0x99FFFFFF,
  ); // white.withOpacity(0.6)
  static const Color textWhiteOpacity70 = Color(
    0xB3FFFFFF,
  ); // white.withOpacity(0.7)
  static const Color textWhiteOpacity40 = Color(
    0x66FFFFFF,
  ); // white.withOpacity(0.4)

  // Divider Colors
  static const Color dividerLight = Color(0x1AFFFFFF); // #FFFFFF1A

  // Interactive Colors
  static const Color likePink = Color(0xFFFF4081); // Material pink
  static const Color unfollowPink = Color(0xFFF20E8E); // Unfollow button
  static const Color iconGrey = Color(0xFF707070);

  // Search & Input Colors
  static const Color searchGradientStart = Color.fromRGBO(80, 76, 88, 0.2);
  static const Color searchGradientEnd = Color.fromRGBO(255, 255, 255, 0.05);

  // Create Post Button Colors
  static const Color createPostButtonShadow = Color(0x47222A37); // #222A3747
  static const Color createPostButtonInnerShadow = Color(
    0x40000000,
  ); // #00000040

  // Create Post Button Gradients
  // Ellipse1 gradient: 179.53deg, #20AEFE 0.41%, #135FFF 100.42%
  static const Color createPostGradientStart = Color(0xFF20AEFE);
  static const Color createPostGradientEnd = Color(0xFF135FFF);

  // Ellipse2 gradient: 146.98deg, #CFEFFF -10.7%, #57BBEB 90.73%
  static const Color createPostGlowStart = Color(0xFFCFEFFF);
  static const Color createPostGlowEnd = Color(0xFF57BBEB);

  // Border gradient: 131.74deg, #FFFFFF -55.4%, rgba(255, 255, 255, 0) 100%
  static const Color createPostBorderStart = Color(0xFFFFFFFF);
  static const Color createPostBorderEnd = Color(0x00FFFFFF);

  // Active Status Indicator Colors
  static const Color activeIndicatorBackground = Color(0xFFC6FFED);
  static const Color activeIndicatorBorder = Color(0xFF00FFAE);
  static const Color inactiveIndicatorBackground = Color(0xFFFFC6C6);
  static const Color inactiveIndicatorBorder = Color(0xFFFF4000);
}
