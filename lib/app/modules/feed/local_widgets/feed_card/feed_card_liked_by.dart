import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';
import 'feed_card_stacked_avatars.dart';

class FeedCardLikedBy extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final String? likedByUsername;

  const FeedCardLikedBy({
    super.key,
    this.isLiked = false,
    this.likesCount = 0,
    this.likedByUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FeedCardStackedAvatars(),
        Expanded(
          child: Transform.translate(
            offset: Offset(-8.w, 0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'likedBy'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isLiked && likedByUsername != null) ...[
                    TextSpan(
                      text: likedByUsername,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'and'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  TextSpan(
                    text: '$likesCount ${'others'.tr}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
