import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'audio_player/audio_player_widget.dart';
import 'event_tablet.dart';
import 'video_player/video_player_widget.dart';

class ContentCard1 extends StatelessWidget {
  final String? imagePath;
  final String? videoUrl;
  final String? audioUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final int? pointsToEarn;
  final String title;
  final String description;
  final bool showAudioPlayer;
  final bool showVideoPlayer;
  final String? contentId;
  final VoidCallback? onButtonTap;
  final VoidCallback? onTap;
  final bool showSolutionButton;
  final bool showTopIcon;
  const ContentCard1({
    super.key,
    this.imagePath,
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.pointsToEarn,
    this.showVideoPlayer = false,
    required this.title,
    required this.description,
    this.showAudioPlayer = false,
    this.contentId,
    this.onButtonTap,
    this.onTap,
    this.showSolutionButton = true,
    this.showTopIcon = false,
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
          if (showTopIcon == true) ...[
            SvgPicture.asset(
              AppImages.vodIcon,
              width: 16.w,
              height: 16.h,
              fit: BoxFit.contain,
            ),
          ],
          if (showAudioPlayer && pointsToEarn != null)
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
                SizedBox(height: 14),
              ],
            ),
          if (!showVideoPlayer)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagePath != null && imagePath!.isNotEmpty)
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
                      child: imagePath!.startsWith('http')
                          ? Image.network(
                              imagePath!,
                              width: 68.w,
                              height: 86.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 68.w,
                                  height: 86.h,
                                  color: AppColors.textWhiteOpacity60,
                                );
                              },
                            )
                          : Image.asset(
                              imagePath!,
                              width: 68.w,
                              height: 86.h,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                if (imagePath != null && imagePath!.isNotEmpty)
                  SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w600,
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
                      SizedBox(
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
          if (showVideoPlayer) ...[
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
            // Video Player
            VideoPlayerWidget(
              videoUrl: videoUrl,
              thumbnailUrl: thumbnailUrl,
              thumbnailImage: thumbnailImage,
              tag: contentId != null
                  ? 'video_$contentId'
                  : videoUrl ?? 'video_${title.hashCode}',
            ),
          ],
          if (showAudioPlayer && !showVideoPlayer) ...[
            SizedBox(height: 16.h),
            AudioPlayerWidget(
              audioUrl: audioUrl,
              tag: contentId != null
                  ? 'audio_$contentId'
                  : audioUrl ?? 'audio_${title.hashCode}',
            ),
            if (showSolutionButton)
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
          if (!showVideoPlayer && !showAudioPlayer) ...[
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IntrinsicWidth(
                  child: EventTablet(
                    text: 'contentCardViewing'.tr,
                    extraPadding: EdgeInsets.symmetric(horizontal: 36.w),
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
