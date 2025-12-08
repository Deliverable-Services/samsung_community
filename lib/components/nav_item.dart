import 'package:flutter/material.dart';
import 'package:samsung_community/constants/colors.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 67,
        height: 62,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: AppColors.shadow,
              offset: Offset(0, 2),
            )
          ],
          gradient: LinearGradient(
            colors: [
              isActive ? AppColors.navGradientStartActive : AppColors.navGradientStart,
              isActive ? AppColors.navGradientEndActive : AppColors.navGradientEnd,
            ],
            stops: const [0, 1],
            begin: const AlignmentDirectional(0, 1),
            end: const AlignmentDirectional(0, -1),
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.navBorderActive : AppColors.navBorderInactive,
            width: isActive ? 1.0 : 0.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

