import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isFromCurrentUser;
  final String? avatarUrl;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isFromCurrentUser) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.createPostGradientStart, AppColors.createPostGradientEnd],
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.overlayContainerBackground,
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(AppImages.avatar, fit: BoxFit.cover);
                      },
                    )
                  : Image.asset(AppImages.avatar, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(20.r),
                ),
                color: AppColors.overlayContainerBackground,
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

