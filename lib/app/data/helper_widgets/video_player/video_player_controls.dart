import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../skeleton_loader.dart';
import '../video_modal.dart';
import 'media_slider.dart';

class VideoPlayerControls extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final double sliderValue;
  final bool showMinimizeIcon;
  final VoidCallback? onMinimize;
  final Function(double) onSliderChanged;
  final VoidCallback onSliderChangeEnd;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final dynamic controller;
  final bool isFullScreen;

  const VideoPlayerControls({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.sliderValue,
    this.showMinimizeIcon = false,
    this.onMinimize,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
    this.videoUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.controller,
    this.isFullScreen = false,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeDisplay() {
    if (totalDuration.inSeconds == 0) {
      return Row(
        children: [
          Text(
            '00:00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '/ ',
            style: TextStyle(
              color: AppColors.accentBlueLight,
              fontSize: 12.sp,
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          SkeletonLoader(
            width: 30.w,
            height: 12.h,
            baseColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.4),
            borderRadius: 2,
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          _formatDuration(currentPosition),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '/ ${_formatDuration(totalDuration)}',
          style: TextStyle(
            color: AppColors.accentBlueLight,
            fontSize: 12.sp,
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMaximizeButton(BuildContext context) {
    if (showMinimizeIcon) {
      if (onMinimize == null) return const SizedBox.shrink();
      return GestureDetector(
        onTap: onMinimize,
        child: Image.asset(AppImages.minimizeIcon, width: 20.w, height: 20.h),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => VideoModal(
              videoUrl: videoUrl,
              thumbnailUrl: thumbnailUrl,
              thumbnailImage: thumbnailImage,
              controller: controller,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      child: Image.asset(AppImages.maximizeIcon, width: 20.w, height: 20.h),
    );
  }

  Widget _buildSlider(BuildContext context) {
    return MediaSlider(
      value: sliderValue,
      onChanged: onSliderChanged,
      onChangeEnd: onSliderChangeEnd,
      activeTrackColor: isFullScreen
          ? const Color(0xFF8CB5FF)
          : AppColors.accentBlueLight,
      inactiveTrackColor: isFullScreen
          ? const Color(0xFF4A4A4A)
          : AppColors.backgroundGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeDisplay(),
                  if (showMinimizeIcon && onMinimize != null)
                    GestureDetector(
                      onTap: onMinimize,
                      child: Image.asset(
                        AppImages.minimizeIcon,
                        width: 20.w,
                        height: 20.h,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Builder(builder: (context) => _buildSlider(context)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.backgroundDark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeDisplay(),
              Builder(builder: (context) => _buildMaximizeButton(context)),
            ],
          ),
          SizedBox(height: 8.h),
          Builder(builder: (context) => _buildSlider(context)),
        ],
      ),
    );
  }
}
