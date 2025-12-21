import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as video_player;

import '../../constants/app_colors.dart';
import 'video_player_controller.dart';
import 'video_player_full_screen_layout.dart';
import 'video_player_layouts.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final video_player.VideoPlayerController? controller;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final Function(Duration)? onSeek;
  final VoidCallback? onReplay;
  final bool showMinimizeIcon;
  final VoidCallback? onMinimize;
  final bool fullScreen;
  final String? tag;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.controller,
    this.onPlay,
    this.onPause,
    this.onSeek,
    this.onReplay,
    this.showMinimizeIcon = false,
    this.onMinimize,
    this.fullScreen = false,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final controllerTag = tag ?? videoUrl ?? 'video_player';
    VideoPlayerControllerGetX videoController;
    try {
      videoController = Get.find<VideoPlayerControllerGetX>(tag: controllerTag);
      if (videoController.videoUrl != videoUrl) {
        Get.delete<VideoPlayerControllerGetX>(tag: controllerTag);
        videoController = Get.put(
          VideoPlayerControllerGetX(
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            thumbnailImage: thumbnailImage,
            onPlay: onPlay,
            onPause: onPause,
            onSeek: onSeek,
            controller: controller,
          ),
          tag: controllerTag,
        );
      }
    } catch (_) {
      videoController = Get.put(
        VideoPlayerControllerGetX(
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          thumbnailImage: thumbnailImage,
          onPlay: onPlay,
          onPause: onPause,
          onSeek: onSeek,
          controller: controller,
        ),
        tag: controllerTag,
      );
    }

    return Obx(() {
      final aspectRatio = videoController.getAspectRatio();
      final borderRadius = fullScreen
          ? BorderRadius.zero
          : BorderRadius.circular(16.r);

      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AppColors.backgroundDark,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: _buildLayout(videoController, aspectRatio),
        ),
      );
    });
  }

  Widget _buildLayout(
    VideoPlayerControllerGetX controller,
    double aspectRatio,
  ) {
    if (fullScreen) {
      return VideoPlayerFullScreenLayout(
        aspectRatio: aspectRatio,
        isInitialized: controller.isInitialized.value,
        isPlaying: controller.isPlaying.value,
        hasError: controller.hasError.value,
        isLoading: controller.isLoading.value,
        isBuffering: controller.isBuffering.value,
        errorMessage: controller.errorMessage.value,
        controller: controller.controller,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        thumbnailImage: thumbnailImage,
        currentPosition: controller.currentPosition.value,
        totalDuration: controller.totalDuration.value,
        sliderValue: controller.getSliderValue(),
        showMinimizeIcon: showMinimizeIcon,
        onMinimize: onMinimize,
        onSliderChanged: controller.onSliderChanged,
        onSliderChangeEnd: controller.onSliderChangeEnd,
        onPlayButtonTapped: controller.onPlayButtonTapped,
        onTogglePlayPause: controller.togglePlayPause,
        onRetry: controller.handleRetry,
      );
    }

    return VideoPlayerNormalLayout(
      aspectRatio: aspectRatio,
      isInitialized: controller.isInitialized.value,
      isPlaying: controller.isPlaying.value,
      hasError: controller.hasError.value,
      isLoading: controller.isLoading.value,
      isBuffering: controller.isBuffering.value,
      errorMessage: controller.errorMessage.value,
      controller: controller.controller,
      fullScreen: fullScreen,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      thumbnailImage: thumbnailImage,
      currentPosition: controller.currentPosition.value,
      totalDuration: controller.totalDuration.value,
      sliderValue: controller.getSliderValue(),
      showMinimizeIcon: showMinimizeIcon,
      onMinimize: onMinimize,
      onSliderChanged: controller.onSliderChanged,
      onSliderChangeEnd: controller.onSliderChangeEnd,
      onPlayButtonTapped: controller.onPlayButtonTapped,
      onRetry: controller.handleRetry,
    );
  }
}
