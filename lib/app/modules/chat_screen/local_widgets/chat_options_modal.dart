import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/option_item.dart';
import '../controllers/chat_screen_controller.dart';

class ChatOptionsModal extends StatelessWidget {
  final ChatScreenController controller;

  const ChatOptionsModal({super.key, required this.controller});

  static void show(BuildContext context, ChatScreenController controller) {
    BottomSheetModal.show(
      context,
      content: ChatOptionsModal(controller: controller),
      buttonType: BottomSheetButtonType.close,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionItem(
          text: 'report'.tr,
          boxTextWidget: SvgPicture.asset(
            AppImages.reportIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            controller.showReportSuccessModal();
          },
        ),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'block'.tr,
          boxTextWidget: SvgPicture.asset(
            AppImages.blockIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            controller.blockUser();
          },
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
