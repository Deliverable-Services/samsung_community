import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'event_tablet.dart';
import 'read_more_text.dart';
import 'video_player/video_player_widget.dart';

class EventBuyingBottomBarModal extends StatelessWidget {
  final String title;
  final String description;
  final String? points;
  final String? date;
  final String? timing;
  final String? text;
  final VoidCallback? onButtonTap;
  final EdgeInsets? extraPaddingForButton;
  final String? mediaUrl;
  final bool isVideo;

  const EventBuyingBottomBarModal({
    super.key,
    required this.title,
    this.points,
    this.date,
    this.timing,
    required this.description,
    this.text,
    this.onButtonTap,
    this.extraPaddingForButton,
    this.mediaUrl,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        EventTablet(
                          widget: Text(
                            date ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                              letterSpacing: 0,
                              color: AppColors.white,
                              fontFamily: 'Samsung Sharp Sans',
                            ),
                          ),
                          extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
                          onTap: () {},
                        ),
                        SizedBox(width: 8),
                        if (timing != null && timing!.isNotEmpty) ...[
                          EventTablet(
                            widget: Text(
                              timing ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                                letterSpacing: 0,
                                color: AppColors.white,
                                fontFamily: 'Samsung Sharp Sans',
                              ),
                            ),
                            extraPadding: EdgeInsets.symmetric(
                              vertical: -2.5.w,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Description with read more
                    ReadMoreText(text: description, maxLines: 5),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        EventTablet(
                          widget: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                "${'homePoints'.tr} $points",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                  letterSpacing: 0,
                                  color: AppColors.white,
                                  fontFamily: 'Samsung Sharp Sans',
                                ),
                              ),
                            ],
                          ),
                          extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
                          onTap: () {},
                        ),
                      ],
                    ),
                    // Media (Video or Image)
                    if (mediaUrl != null && mediaUrl!.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      if (isVideo)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: VideoPlayerWidget(
                            videoUrl: mediaUrl,
                            tag:
                                'workshop_${DateTime.now().millisecondsSinceEpoch}',
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: CachedNetworkImage(
                            imageUrl: mediaUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200.h,
                              color: AppColors.backgroundDark,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Container(
                                height: 200.h,
                                color: AppColors.backgroundDark,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.textWhiteOpacity60,
                                    size: 48.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            // Sticky button at bottom
            Padding(
              padding: EdgeInsets.only(bottom: 10.h, top: 20.h),
              child: Center(
                child: AppButton(
                  onTap: onButtonTap,
                  text: text ?? 'registration'.tr,
                  width: double.infinity,
                  height: 48.h,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RegistrationSuccessModal extends StatelessWidget {
  final String title;
  final String text;
  final String icon;
  final String description;
  final VoidCallback? onButtonTap;
  final EdgeInsets? extraPaddingForButton;

  const RegistrationSuccessModal({
    super.key,
    required this.title,
    required this.text,
    required this.icon,
    required this.description,
    this.onButtonTap,
    this.extraPaddingForButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        SvgPicture.asset(icon, fit: BoxFit.contain),
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontSize: 14.sp,
            height: 22 / 14,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 20.h),
        Center(
          child: AppButton(
            onTap: onButtonTap,
            text: text,
            width: double.infinity,
            height: 48.h,
          ),
        ),
      ],
    );
  }
}
