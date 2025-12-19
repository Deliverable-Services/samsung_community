import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import 'event_tablet.dart';

class StoreCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const StoreCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          stops: [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, 7.43.h),
            blurRadius: 16.6.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // subContainerLeft (image)
              Container(
                width: 68.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    width: 2,
                    color: AppColors.textWhiteOpacity60,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.asset(
                    imagePath,
                    width: 68.w,
                    height: 86.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // subContainerRight
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight:
                            FontWeight.w600, // 666 seems like typo, using 600
                        fontSize: 16.sp,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.textWhite,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // Description
                    SizedBox(
                      width: 250.w,
                      child: Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontSize: 14.sp,
                          height: 22 / 14,
                          letterSpacing: 0,
                          color: AppColors.textWhiteSecondary,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Tablet at bottom right, aligned to right
          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IntrinsicWidth(
                child: EventTablet(
                  text: 'storeCardViewing'.tr,
                  extraPadding: EdgeInsets.symmetric(horizontal: 36.w),
                  onTap: () {
                    // TODO: Handle button tap
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
