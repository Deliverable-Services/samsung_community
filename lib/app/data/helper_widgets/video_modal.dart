import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_colors.dart';
import 'video_player_widget.dart';

class VideoModal extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final VideoPlayerController? controller;

  const VideoModal({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.controller,
  });

  @override
  State<VideoModal> createState() => _VideoModalState();
}

class _VideoModalState extends State<VideoModal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: VideoPlayerWidget(
              videoUrl: widget.videoUrl,
              thumbnailUrl: widget.thumbnailUrl,
              thumbnailImage: widget.thumbnailImage,
              controller: widget.controller,
              showMinimizeIcon: true,
              onMinimize: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              fullScreen: true,
            ),
          ),
          Positioned(
            top: 16.h,
            right: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundDarkMedium.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.textWhite,
                  size: 24.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
