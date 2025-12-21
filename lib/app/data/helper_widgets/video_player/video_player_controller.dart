import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as video_player;

import 'video_player_manager.dart';

class VideoPlayerControllerGetX extends GetxController {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final Function(Duration)? onSeek;

  video_player.VideoPlayerController? _controller;
  final RxBool isInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isSeeking = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isBuffering = false.obs;
  final RxnString errorMessage = RxnString();
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  VideoPlayerControllerGetX({
    this.videoUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.onPlay,
    this.onPause,
    this.onSeek,
    video_player.VideoPlayerController? controller,
  }) {
    if (controller != null && controller.value.isInitialized) {
      _controller = controller;
      isInitialized.value = true;
      totalDuration.value = controller.value.duration;
      currentPosition.value = controller.value.position;
      isPlaying.value = controller.value.isPlaying;
      controller.addListener(_videoListener);
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (_controller != null) {
      _controller!.addListener(_videoListener);
    }
  }

  Future<void> initializeVideo() async {
    if (videoUrl == null || videoUrl!.isEmpty) return;

    isLoading.value = true;
    try {
      _controller?.dispose();
    } catch (_) {}

    _controller = video_player.VideoPlayerController.networkUrl(
      Uri.parse(videoUrl!),
      videoPlayerOptions: video_player.VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    );

    try {
      await _controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );

      if (_controller!.value.hasError) {
        isLoading.value = false;
        isInitialized.value = false;
        hasError.value = true;
        errorMessage.value = _controller!.value.errorDescription;
        try {
          await _controller?.dispose();
        } catch (_) {}
        _controller = null;
        return;
      }

      isLoading.value = false;
      isInitialized.value = true;
      hasError.value = false;
      errorMessage.value = null;
      totalDuration.value = _controller!.value.duration;
      currentPosition.value = _controller!.value.position;
      isPlaying.value = _controller!.value.isPlaying;
      _controller!.addListener(_videoListener);
    } catch (e) {
      debugPrint('Error initializing video: $e');
      isLoading.value = false;
      isInitialized.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();
      try {
        await _controller?.dispose();
      } catch (_) {}
      _controller = null;
    }
  }

  void _videoListener() {
    if (_controller == null || _controller!.value.hasError) {
      if (!isSeeking.value) {
        hasError.value = true;
        errorMessage.value = _controller?.value.errorDescription;
        isInitialized.value = false;
      }
      return;
    }

    if (!isSeeking.value) {
      currentPosition.value = _controller!.value.position;
      totalDuration.value = _controller!.value.duration;
      isPlaying.value = _controller!.value.isPlaying;
      isBuffering.value = _controller!.value.isBuffering;
    }
  }

  void togglePlayPause() async {
    if (!isInitialized.value) {
      if (videoUrl == null || videoUrl!.isEmpty) return;
      await initializeVideo();
      if (isInitialized.value && _controller != null) {
        if (videoUrl != null) {
          VideoPlayerManager.setCurrentPlayer(_controller!, videoUrl!);
        }
        _controller!.play();
        onPlay?.call();
      }
      return;
    }

    if (_controller == null) return;

    if (isPlaying.value) {
      _controller!.pause();
      VideoPlayerManager.clearCurrentPlayer(_controller!);
      onPause?.call();
    } else {
      if (videoUrl != null) {
        VideoPlayerManager.setCurrentPlayer(_controller!, videoUrl!);
      }
      _controller!.play();
      onPlay?.call();
    }
  }

  void onPlayButtonTapped() {
    if (!isInitialized.value && videoUrl != null && videoUrl!.isNotEmpty) {
      isLoading.value = true;
      initializeVideo().then((_) {
        if (isInitialized.value && _controller != null) {
          if (videoUrl != null) {
            VideoPlayerManager.setCurrentPlayer(_controller!, videoUrl!);
          }
          _controller!.play();
          onPlay?.call();
        }
        isLoading.value = false;
      });
    } else {
      togglePlayPause();
    }
  }

  void seekTo(Duration position) {
    if (_controller == null || !isInitialized.value) return;
    _controller!.seekTo(position);
    onSeek?.call(position);
  }

  void onSliderChanged(double value) {
    if (_controller == null || !isInitialized.value) return;
    isSeeking.value = true;
    final newPosition = Duration(
      milliseconds: (value * totalDuration.value.inMilliseconds).round(),
    );
    seekTo(newPosition);
  }

  void onSliderChangeEnd() {
    isSeeking.value = false;
  }

  double getSliderValue() {
    if (totalDuration.value.inMilliseconds == 0) return 0.0;
    return currentPosition.value.inMilliseconds /
        totalDuration.value.inMilliseconds;
  }

  void handleRetry() {
    hasError.value = false;
    errorMessage.value = null;
    initializeVideo();
  }

  double getAspectRatio() {
    if (isInitialized.value && _controller != null) {
      final size = _controller!.value.size;
      if (size.height > 0) {
        return size.width / size.height;
      }
    }
    return 16 / 9;
  }

  video_player.VideoPlayerController? get controller => _controller;

  @override
  void onClose() {
    if (_controller != null) {
      VideoPlayerManager.clearCurrentPlayer(_controller!);
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    _controller = null;
    super.onClose();
  }
}

