import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'nav_item.dart';

class BottomNavItemData {
  const BottomNavItemData({required this.icon, required this.label});

  final Widget icon;
  final String label;
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  }) : assert(items.length > 1);

  final List<BottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0, 1),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 79,
        decoration: BoxDecoration(
          color: AppColors.bottomNavBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return NavItem(
                icon: item.icon,
                label: item.label,
                isActive: index == currentIndex,
                onTap: () => onItemSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}
