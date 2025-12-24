import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../constants/app_colors.dart';
import 'video_player_error_widget.dart';
import 'video_player_thumbnail.dart';

class VideoPlayerContent extends StatelessWidget {
  final bool hasError;
  final String? errorMessage;
  final bool isInitialized;
  final VideoPlayerController? controller;
  final bool fullScreen;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final String? videoUrl;
  final VoidCallback onRetry;

  const VideoPlayerContent({
    super.key,
    required this.hasError,
    this.errorMessage,
    required this.isInitialized,
    this.controller,
    required this.fullScreen,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.videoUrl,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return VideoPlayerErrorWidget(
        errorMessage: errorMessage,
        fullScreen: fullScreen,
        onRetry: onRetry,
      );
    }

    if (isInitialized && controller != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: fullScreen ? BoxFit.contain : BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: VideoPlayer(controller!),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: fullScreen
            ? const Color(0xFF2A2A2A)
            : AppColors.backgroundDarkMedium,
      ),
      child: VideoPlayerThumbnail(
        thumbnailUrl: thumbnailUrl,
        thumbnailImage: thumbnailImage,
        videoUrl: videoUrl,
      ),
    );
  }
}
