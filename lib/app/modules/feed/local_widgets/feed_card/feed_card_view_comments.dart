import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';

class FeedCardViewComments extends StatelessWidget {
  final int commentsCount;
  final VoidCallback? onViewComments;

  const FeedCardViewComments({
    super.key,
    this.commentsCount = 0,
    this.onViewComments,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewComments,
      child: Text(
        '${'viewAllComments'.tr} $commentsCount ${'viewAllCommentsSuffix'.tr}',
        style: TextStyle(
          fontFamily: 'Samsung Sharp Sans',
          fontSize: 12.sp,
          color: AppColors.textWhiteOpacity60,
        ),
      ),
    );
  }
}

