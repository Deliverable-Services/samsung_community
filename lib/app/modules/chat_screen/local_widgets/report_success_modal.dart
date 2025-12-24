import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/constants/app_button.dart';

class ReportSuccessModal extends StatelessWidget {
  const ReportSuccessModal({super.key});

  static void show(BuildContext context) {
    BottomSheetModal.show(
      context,
      content: const ReportSuccessModal(),
      buttonType: BottomSheetButtonType.close,
      isScrollControlled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          child: SvgPicture.asset(
            AppImages.reportedIcon,
            width: 50.w,
            height: 50.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'reportSubmittedSuccessfully'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Text(
          'reportSuccessMessage'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.textWhiteOpacity70,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        AppButton(
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          text: 'close'.tr,
          width: double.infinity,
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
