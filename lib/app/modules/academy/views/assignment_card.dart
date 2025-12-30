import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/audio_player/audio_player_widget.dart';
import '../../../data/helper_widgets/event_tablet.dart';
import '../../../data/models/weekly_riddle_model.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentCardType type;
  final String? imagePath;
  final String? audioUrl;
  final int? pointsToEarn;
  final String title;
  final String description;
  final bool showAudioPlayer;
  final String? contentId;
  final VoidCallback? onButtonTap;
  final bool isAudio;
  final bool isSubmitted;

  const AssignmentCard({
    super.key,
    required this.type,
    this.imagePath,
    this.audioUrl,
    this.pointsToEarn,
    required this.title,
    required this.description,
    this.showAudioPlayer = false,
    this.contentId,
    this.onButtonTap,
    this.isAudio = false,
    this.isSubmitted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          /// 🔵 Bottom blue ellipse (FIXED)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0076FF).withOpacity(0.1),
                      const Color(0xFF0076FF).withOpacity(0.2),
                    ],
                    stops: const [0.50, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ),

          /// 🧩 Main card surface
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.cardGradientStart,
                  AppColors.cardGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0, 7.43.h),
                  blurRadius: 16.6.r,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ⭐ Header
                if (pointsToEarn != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        AppImages.magicIcon,
                        width: 44.w,
                        height: 44.h,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppImages.pointsIcon,
                            width: 18.w,
                            height: 18.h,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            "+$pointsToEarn",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                ],

                /// 🏷 Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 24 / 16,
                    color: Colors.white,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),

                SizedBox(height: 4.h),

                /// 📝 Description (NO blue behind now)
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontSize: 14.sp,
                    height: 22 / 14,
                    color: const Color(0xFFBDBDBD),
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),

                /// 🔊 Audio
                if (isAudio)
                  AudioPlayerWidget(
                    audioUrl: audioUrl,
                    tag: contentId != null
                        ? 'audio_$contentId'
                        : audioUrl ?? 'audio_${title.hashCode}',
                  ),

                SizedBox(height: 20.h),

                /// 📤 CTA (inside blue zone)
                Align(
                  alignment: Alignment.centerRight,
                  child: IntrinsicWidth(
                    child: EventTablet(
                      text: isSubmitted ? 'Submitted' : 'sendSolution'.tr,
                      extraPadding: EdgeInsets.symmetric(horizontal: 36.w),
                      onTap: isSubmitted ? null : onButtonTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
