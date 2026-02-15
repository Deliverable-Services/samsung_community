import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/audio_player/audio_player_widget.dart';
import '../../../data/helper_widgets/event_tablet.dart';
import '../../../data/helper_widgets/read_more_text.dart';
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
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppImages.imageCardBackground),
          ),
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
                  if (type == AssignmentCardType.assignment)
                    SvgPicture.asset(
                      AppImages.magicIcon,
                      width: 44.w,
                      height: 44.h,
                    ),
                  if (type == AssignmentCardType.riddle)
                    SvgPicture.asset(
                      AppImages.assignmentIcon,
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
                          fontFamily: 'Samsung Sharp Sans',
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
            ReadMoreText(
              text: description,
              title: title,
              maxLines: 3,
              textStyle: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                height: 22 / 14,
                color: const Color(0xFFBDBDBD),
              ),
            ),

            /// 🔊 Audio
            SizedBox(height: 16.h),
            if (isAudio)
              AudioPlayerWidget(
                audioUrl: audioUrl,
                tag: contentId != null
                    ? 'audio_$contentId'
                    : audioUrl ?? 'audio_${title.hashCode}',
              ),

            SizedBox(height: 20.h),

            /// 📤 CTA — automatically flips for RTL (Hebrew) / LTR (English)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IntrinsicWidth(
                child: EventTablet(
                  text: isSubmitted ? 'submitted'.tr : 'sendSolution'.tr,
                  extraPadding: EdgeInsets.symmetric(horizontal: 36.w),
                  onTap: isSubmitted ? null : onButtonTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
