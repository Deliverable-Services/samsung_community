import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/audio_player/audio_player_widget.dart';
import '../../../data/helper_widgets/event_tablet.dart';

class AssignmentCard extends StatelessWidget {
  final String? imagePath;
  final String? audioUrl;
  final int? pointsToEarn;
  final String title;
  final String description;
  final bool showAudioPlayer;
  final String? contentId;
  final VoidCallback? onButtonTap;
  final bool isAudio;

  const AssignmentCard({
    super.key,
    this.imagePath,
    this.audioUrl,
    this.pointsToEarn,
    required this.title,
    required this.description,
    this.showAudioPlayer = false,
    this.contentId,
    this.onButtonTap,
    this.isAudio = false,
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
          if (pointsToEarn != null)
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      AppImages.magicIcon,
                      width: 44.w,
                      height: 44.h,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: SvgPicture.asset(
                            AppImages.pointsIcon,
                            width: 18.w,
                            height: 18.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "$pointsToEarn",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
              ],
            ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              height: 24 / 16,
              letterSpacing: 0,
              color: const Color(0xFFFFFFFF),
            ),
            textScaler: const TextScaler.linear(1.0),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 14.sp,
              height: 22 / 14,
              letterSpacing: 0,
              color: const Color(0xFFBDBDBD),
            ),
            textScaler: const TextScaler.linear(1.0),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          if (isAudio)
            AudioPlayerWidget(
              audioUrl: audioUrl,
              tag: contentId != null
                  ? 'audio_$contentId'
                  : audioUrl ?? 'audio_${title.hashCode}',
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IntrinsicWidth(
                child: EventTablet(
                  text: 'sendSolution'.tr,
                  extraPadding: EdgeInsets.symmetric(horizontal: 36.w),
                  onTap: onButtonTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
