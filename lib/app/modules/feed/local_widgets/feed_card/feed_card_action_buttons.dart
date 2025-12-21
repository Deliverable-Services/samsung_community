import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_images.dart';

class FeedCardActionButtons extends StatelessWidget {
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const FeedCardActionButtons({
    super.key,
    this.isLiked = false,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.likePink : AppColors.textWhite,
            size: 21.sp,
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: onComment,
          child: Image.asset(
            AppImages.commentIcon,
            width: 16.w,
            height: 16.h,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}

