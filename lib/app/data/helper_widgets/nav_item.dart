import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          isActive
              ? AppColors.navGradientStartActive
              : AppColors.navGradientStart,
          isActive ? AppColors.navGradientEndActive : AppColors.navGradientEnd,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isActive
            ? AppColors.navBorderActive
            : AppColors.navBorderInactive,
        width: isActive ? 1.0 : 0.0,
      ),
      // Same multi-layer shadow stack for both active and inactive items
      boxShadow: const [
        BoxShadow(
          // 0px 7.43px 16.6px 0px #0000001A
          color: Color(0x1A000000),
          offset: Offset(0, 7.43),
          blurRadius: 16.6,
        ),
        BoxShadow(
          // 0px 30.15px 30.15px 0px #00000017
          color: Color(0x17000000),
          offset: Offset(0, 30.15),
          blurRadius: 30.15,
        ),
        BoxShadow(
          // 0px 68.16px 41.07px 0px #0000000D
          color: Color(0x0D000000),
          offset: Offset(0, 68.16),
          blurRadius: 41.07,
        ),
        BoxShadow(
          // 0px 121.02px 48.5px 0px #00000003
          color: Color(0x03000000),
          offset: Offset(0, 121.02),
          blurRadius: 48.5,
        ),
      ],
    );

    Widget content = Container(
      width: 67,
      height: 62,
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 35 / 12,
              letterSpacing: 0.0,
              color: isActive
                  ? AppColors.navTextActive
                  : AppColors.navTextInactive,
              fontFamily: 'Samsung Sharp Sans',
            ),
          ),
        ],
      ),
    );

    // Apply backdrop blur for both active and inactive, as per spec
    content = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        // backdrop-filter: blur(7.8643px)
        filter: ImageFilter.blur(
          sigmaX: 7.864322662353516,
          sigmaY: 7.864322662353516,
        ),
        child: content,
      ),
    );

    return GestureDetector(onTap: onTap, child: content);
  }
}
