import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

class VideoPlayerErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final bool fullScreen;
  final VoidCallback onRetry;

  const VideoPlayerErrorWidget({
    super.key,
    this.errorMessage,
    required this.fullScreen,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: fullScreen
            ? const Color(0xFF2A2A2A)
            : AppColors.backgroundDarkMedium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white70, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Unable to play video',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontFamily: 'Samsung Sharp Sans',
            ),
          ),
          if (errorMessage != null && kDebugMode)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                errorMessage!,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10.sp,
                  fontFamily: 'Samsung Sharp Sans',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontFamily: 'Samsung Sharp Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
