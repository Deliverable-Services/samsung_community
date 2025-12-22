import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';

import '../../routes/app_pages.dart';
import '../constants/app_images.dart';
import 'bottom_sheet_modal.dart';
import 'option_item.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  static void show(BuildContext context) {
    BottomSheetModal.show(
      context,
      content: const SettingsModal(),
      buttonType: BottomSheetButtonType.close,
    );
  }

  void _handleEditAccountDetails(BuildContext context) {
    // Navigate to edit profile after modal closes
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.toNamed(Routes.EDIT_PROFILE);
    });
  }

  void _handleBlockedUsers(BuildContext context) {
    // Navigate after a brief delay - this will push on top of profile
    Future.delayed(const Duration(milliseconds: 250), () {
      Get.toNamed(Routes.BLOCKED_USERS);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionItem(
          text: 'editAccountDetails'.tr,
          boxTextWidget: SvgPicture.asset(AppImages.editProfileIcon),
          onTap: () => _handleEditAccountDetails(context),
        ),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'blockedUsers'.tr,
          boxTextWidget: SvgPicture.asset(AppImages.blockIcon),
          onTap: () => _handleBlockedUsers(context),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
