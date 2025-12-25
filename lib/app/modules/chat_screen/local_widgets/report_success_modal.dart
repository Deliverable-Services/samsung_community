import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/alert_modal.dart';

class ReportSuccessModal {
  static void show(BuildContext context) {
    AlertModal.show(
      context,
      iconPath: AppImages.reportedIcon,
      iconWidth: 50,
      iconHeight: 50,
      title: 'reportSubmittedSuccessfully'.tr,
      description: 'reportSuccessMessage'.tr,
      buttonText: 'close'.tr,
      isScrollControlled: false,
    );
  }
}
