import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import 'bottom_sheet_modal.dart';

class AlertModal extends StatelessWidget {
  final Widget? icon;
  final String? iconPath;
  final double? iconWidth;
  final double? iconHeight;
  final String title;
  final String? description;
  final String buttonText;
  final VoidCallback? onButtonTap;

  const AlertModal({
    super.key,
    this.icon,
    this.iconPath,
    this.iconWidth,
    this.iconHeight,
    required this.title,
    this.description,
    required this.buttonText,
    this.onButtonTap,
  }) : assert(
         (icon != null && iconPath == null) ||
             (icon == null && iconPath != null) ||
             (icon == null && iconPath == null),
         'Either provide icon widget or iconPath, or neither',
       );

  static void show(
    BuildContext context, {
    Widget? icon,
    String? iconPath,
    double? iconWidth,
    double? iconHeight,
    required String title,
    String? description,
    required String buttonText,
    VoidCallback? onButtonTap,
    bool isScrollControlled = false,
  }) {
    BottomSheetModal.show(
      context,
      content: AlertModal(
        icon: icon,
        iconPath: iconPath,
        iconWidth: iconWidth,
        iconHeight: iconHeight,
        title: title,
        description: description,
        buttonText: buttonText,
        onButtonTap: onButtonTap,
      ),
      buttonType: BottomSheetButtonType.close,
      isScrollControlled: isScrollControlled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          icon!
        else if (iconPath != null)
          SizedBox(
            width: iconWidth ?? 50.w,
            height: iconHeight ?? 50.h,
            child: SvgPicture.asset(
              iconPath!,
              width: iconWidth ?? 50.w,
              height: iconHeight ?? 50.h,
              fit: BoxFit.contain,
            ),
          ),
        if ((icon != null || iconPath != null)) SizedBox(height: 20.h),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          SizedBox(height: 16.h),
          Text(
            description!,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: AppColors.textWhiteOpacity70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: 30.h),
        AppButton(
          onTap:
              onButtonTap ??
              () {
                Navigator.of(context, rootNavigator: true).pop();
              },
          text: buttonText,
          width: double.infinity,
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
