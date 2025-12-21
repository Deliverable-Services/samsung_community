import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerStateManager {
  VideoPlayerController? controller;
  bool isInitialized = false;
  bool isPlaying = false;
  bool isSeeking = false;
  bool hasError = false;
  bool isLoading = false;
  bool isBuffering = false;
  String? errorMessage;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  Future<void> initializeVideo(
    String videoUrl,
    Function(VideoPlayerController) onInitialized,
    Function(String) onError,
  ) async {
    isLoading = true;
    try {
      controller?.dispose();
    } catch (_) {}

    controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );

    try {
      await controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );

      if (controller!.value.hasError) {
        isLoading = false;
        isInitialized = false;
        hasError = true;
        errorMessage = controller!.value.errorDescription;
        try {
          await controller?.dispose();
        } catch (_) {}
        controller = null;
        onError(errorMessage ?? 'Unknown error');
        return;
      }

      isLoading = false;
      isInitialized = true;
      hasError = false;
      errorMessage = null;
      totalDuration = controller!.value.duration;
      currentPosition = controller!.value.position;
      isPlaying = controller!.value.isPlaying;
      onInitialized(controller!);
    } catch (e) {
      debugPrint('Error initializing video: $e');
      isLoading = false;
      isInitialized = false;
      hasError = true;
      errorMessage = e.toString();
      try {
        await controller?.dispose();
      } catch (_) {}
      controller = null;
      onError(e.toString());
    }
  }

  void updateFromController() {
    if (controller == null || controller!.value.hasError) {
      if (!isSeeking) {
        hasError = true;
        errorMessage = controller?.value.errorDescription;
        isInitialized = false;
      }
      return;
    }

    if (!isSeeking) {
      currentPosition = controller!.value.position;
      totalDuration = controller!.value.duration;
      isPlaying = controller!.value.isPlaying;
      isBuffering = controller!.value.isBuffering;
    }
  }

  void dispose() {
    if (controller != null) {
      controller!.dispose();
      controller = null;
    }
  }
}
