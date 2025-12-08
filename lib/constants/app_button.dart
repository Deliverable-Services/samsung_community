import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color textColor;
  final double width, height;

  const AppButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width = 350,
    this.height = 48,
    this.textColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navGradientStartActive,
                  AppColors.navGradientEndActive,
                ],
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.navBorderActive.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 7.43),
                  blurRadius: 16.6,
                  color: AppColors.buttonShadow,
                ),
                BoxShadow(
                  offset: Offset(0, 30.15),
                  blurRadius: 30.15,
                  color: AppColors.buttonShadowMedium,
                ),
                BoxShadow(
                  offset: Offset(0, 68.16),
                  blurRadius: 41.07,
                  color: AppColors.buttonShadowLight,
                ),
                BoxShadow(
                  offset: Offset(0, 121.02),
                  blurRadius: 48.5,
                  color: AppColors.buttonShadowExtraLight,
                ),
                BoxShadow(
                  offset: Offset(0, 189.18),
                  blurRadius: 52.87,
                  color: AppColors.shadowTransparent,
                ),
              ],
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.transparent,
                shadowColor: AppColors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: textColor,
                  letterSpacing: 0.0,
                  shadows: [
                    Shadow(
                      color: AppColors.buttonShadow,
                      offset: const Offset(0.0, 7.43),
                      blurRadius: 16.6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
