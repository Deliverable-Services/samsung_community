import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class VideoPlayerPlayButton extends StatelessWidget {
  final bool fullScreen;
  final VoidCallback onTap;

  const VideoPlayerPlayButton({
    super.key,
    required this.fullScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 25.r,
                  spreadRadius: 8.r,
                ),
              ],
            ),
            child: Icon(Icons.play_arrow, color: Colors.white, size: 45.sp),
          ),
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80.w,
          height: 80.h,
          child: Center(
            child: Image.asset(AppImages.playButton, width: 62.w, height: 62.w),
          ),
        ),
      ),
    );
  }
}
