class AppDesign {
  AppDesign._();

  static const double figmaWidth = 390.0;
  static const double figmaHeight = 905.0;

  static double calculateResponsiveSize({
    required double screenWidth,
    required double baseSize,
    required double viewportPercentage,
  }) {
    return baseSize + (screenWidth * viewportPercentage / 100);
  }

  static double figmaToResponsive({
    required double screenWidth,
    required double figmaValue,
    double? baseSize,
  }) {
    final base = baseSize ?? (figmaValue * 0.25);
    final percentage = ((figmaValue - base) / figmaWidth) * 100;
    return calculateResponsiveSize(
      screenWidth: screenWidth,
      baseSize: base,
      viewportPercentage: percentage,
    );
  }
}
