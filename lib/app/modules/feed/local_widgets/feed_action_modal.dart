import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/option_item.dart';

class FeedActionModal extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final bool isOwnPost;

  const FeedActionModal({
    super.key,
    this.onDelete,
    this.onShare,
    this.isOwnPost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOwnPost) ...[
          OptionItem(
            boxTextWidget: Image.asset(AppImages.trashIcon),
            text: 'delete'.tr,
            onTap: () {
              onDelete?.call();
              Get.back();
            },
          ),
          SizedBox(height: 16.h),
        ],
        OptionItem(
          boxTextWidget: Image.asset(AppImages.sendIcon),
          text: 'share'.tr,
          onTap: () {
            onShare?.call();
          },
        ),
      ],
    );
  }
}
