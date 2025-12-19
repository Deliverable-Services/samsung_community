import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/option_item.dart';

class FeedActionModal extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const FeedActionModal({
    super.key,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionItem(
          boxTextWidget: Image.asset(AppImages.trashIcon),
          text: 'delete'.tr,
          onTap: () {
            onDelete?.call();
            Get.back();
          },
        ),
        OptionItem(
          boxTextWidget: Image.asset(AppImages.sendIcon),
          text: 'share'.tr,
          onTap: () {
            onShare?.call();
            Get.back();
          },
        ),
      ],
    );
  }
}
