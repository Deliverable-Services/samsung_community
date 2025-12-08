import 'package:flutter/material.dart';
import 'package:samsung_community/constants/colors.dart';

/// Custom header widget showing total points and action icons.
class CustomHeader extends StatelessWidget {
  final int totalPoints;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onMenuPressed;

  const CustomHeader({
    super.key,
    required this.totalPoints,
    this.onNotificationPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPointsSection(context),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildPointsSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            // TODO: Replace with your actual header image asset.
            'asset/images/logo.png',
            width: 36,
            height: 33,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total points',
              style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    // TODO: Replace with your actual points icon asset.
                    'asset/images/logo.png',
                    width: 12,
                    height: 12,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '$totalPoints',
                  style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.0,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_sharp,
          onPressed: onNotificationPressed,
        ),
        const SizedBox(width: 12),
        _HeaderIconButton(
          icon: Icons.menu,
          onPressed: onMenuPressed,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _HeaderIconButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x00D6D6D6), Color(0xFF707070)],
            stops: [0, 1],
            begin: AlignmentDirectional(0, 1),
            end: AlignmentDirectional(0, -1),
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color(0xFF818181),
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 15,
            color: AppColors.white,
          ),
          padding: EdgeInsets.zero,
          splashRadius: 20,
        ),
      ),
    );
  }
}


