import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import 'back_button.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLeading;
  final String text;
  final void Function()? onTap;
  final List<Widget>? actions;
  final Widget? leadingWidget;

  const TitleAppBar({
    super.key,
    required this.text,
    this.onTap,
    this.isLeading = false,
    this.actions,
    this.leadingWidget,
  });

  @override
  AppBar build(BuildContext context) => AppBar(
    backgroundColor: AppColors.primary,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 30.h, // Reduced height
    centerTitle: true,
    title: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20.sp,
        letterSpacing: 0,
        color: AppColors.white,
        height: 1,
        fontFamily: 'Samsung Sharp Sans',
      ),
      textScaler: const TextScaler.linear(1.0),
    ),
    leading: isLeading
        ? leadingWidget ??
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
              )
        : const SizedBox.shrink(),
    automaticallyImplyLeading: false,
    actions: [
      if (actions != null) ...actions!,
      Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Center(
          child: CustomBackButton(
            rotation: 0,
            onTap: onTap ?? () => Get.back(),
          ),
        ),
      ),
    ],
  );

  @override
  Size get preferredSize => Size.fromHeight(30.h); // Match toolbarHeight
}
