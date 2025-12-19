import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/option_item.dart';

class FeedActionModal extends StatelessWidget {
  final int postIndex;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const FeedActionModal({
    super.key,
    required this.postIndex,
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
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        OptionItem(
          boxTextWidget: Image.asset(AppImages.sendIcon),
          text: 'share'.tr,
          onTap: () {
            onShare?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}
