import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/alert_modal.dart';

class RegistrationSuccessModal {
  static void show(BuildContext context) {
    AlertModal.show(
      context,
      iconPath: AppImages.icVerify,
      iconWidth: 60.w,
      iconHeight: 60.h,
      title: 'Registration Successful',
      description: "You're successfully registered for the event.",
      buttonText: 'Close',
      onButtonTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        // Return to events screen
        Get.back();
      },
    );
  }
}

class RegistrationCancelledModal {
  static void show(BuildContext context) {
    AlertModal.show(
      context,
      iconPath: AppImages.icFailed,
      iconWidth: 60.w,
      iconHeight: 60.h,
      title: 'Registration Cancelled',
      description: 'Your event registration has been cancelled.',
      buttonText: 'Close',
      onButtonTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        // Return to events screen
        Get.back();
      },
    );
  }
}
