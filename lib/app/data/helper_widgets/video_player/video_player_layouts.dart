import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../constants/app_colors.dart';
import 'video_player_controls.dart';
import 'video_player_error_widget.dart';
import 'video_player_play_button.dart';
import 'video_player_thumbnail.dart';

class VideoPlayerNormalLayout extends StatelessWidget {
  final double aspectRatio;
  final bool isInitialized;
  final bool isPlaying;
  final bool hasError;
  final bool isLoading;
  final bool isBuffering;
  final String? errorMessage;
  final VideoPlayerController? controller;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final bool fullScreen;
  final Duration currentPosition;
  final Duration totalDuration;
  final double sliderValue;
  final bool showMinimizeIcon;
  final VoidCallback? onMinimize;
  final String? videoUrl;
  final Function(double) onSliderChanged;
  final VoidCallback onSliderChangeEnd;
  final VoidCallback onPlayButtonTapped;
  final VoidCallback onRetry;

  const VideoPlayerNormalLayout({
    super.key,
    required this.aspectRatio,
    required this.isInitialized,
    required this.isPlaying,
    required this.hasError,
    required this.isLoading,
    required this.isBuffering,
    this.errorMessage,
    this.controller,
    this.thumbnailUrl,
    this.thumbnailImage,
    required this.fullScreen,
    required this.currentPosition,
    required this.totalDuration,
    required this.sliderValue,
    required this.showMinimizeIcon,
    this.onMinimize,
    this.videoUrl,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
    required this.onPlayButtonTapped,
    required this.onRetry,
  });

  Widget _buildVideoContent() {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = 600.h;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                minHeight: 200.h,
              ),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Stack(
                  children: [
                    _buildVideoContent(),
                    if (!isPlaying || !isInitialized)
                      VideoPlayerPlayButton(
                        fullScreen: fullScreen,
                        onTap: onPlayButtonTapped,
                        isLoading: isLoading,
                        isBuffering: isBuffering,
                      ),
                    if (isPlaying && isInitialized)
                      GestureDetector(
                        onTap: onPlayButtonTapped,
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        VideoPlayerControls(
          currentPosition: currentPosition,
          totalDuration: totalDuration,
          sliderValue: sliderValue,
          showMinimizeIcon: showMinimizeIcon,
          onMinimize: onMinimize,
          onSliderChanged: onSliderChanged,
          onSliderChangeEnd: onSliderChangeEnd,
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          thumbnailImage: thumbnailImage,
          controller: controller,
          isFullScreen: false,
        ),
      ],
    );
  }
}
