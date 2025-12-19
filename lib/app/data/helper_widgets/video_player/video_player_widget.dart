import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../constants/app_colors.dart';
import 'video_player_full_screen_layout.dart';
import 'video_player_layouts.dart';
import 'video_player_state_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final VideoPlayerController? controller;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final Function(Duration)? onSeek;
  final VoidCallback? onReplay;
  final bool showMinimizeIcon;
  final VoidCallback? onMinimize;
  final bool fullScreen;

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
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final _stateManager = VideoPlayerStateManager();
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      _controller = widget.controller;
      _stateManager.controller = _controller;
      _stateManager.isInitialized = true;
      _stateManager.totalDuration = _controller!.value.duration;
      _stateManager.currentPosition = _controller!.value.position;
      _stateManager.isPlaying = _controller!.value.isPlaying;
      _controller!.addListener(_videoListener);
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;

    await _stateManager.initializeVideo(
      widget.videoUrl!,
      (controller) {
        if (mounted) {
          _controller = controller;
          _controller!.addListener(_videoListener);
          setState(() {
            _stateManager.isInitialized = true;
            _stateManager.hasError = false;
            _stateManager.errorMessage = null;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _stateManager.hasError = true;
            _stateManager.errorMessage = error;
          });
        }
      },
    );
  }

  void _videoListener() {
    if (!mounted) return;
    _stateManager.updateFromController();
    setState(() {});
  }

  void _togglePlayPause() async {
    if (!_stateManager.isInitialized) {
      if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;
      await _initializeVideo();
      if (_stateManager.isInitialized && _controller != null) {
        _controller!.play();
        widget.onPlay?.call();
        return;
      }
      return;
    }

    if (_controller == null) return;

    if (_stateManager.isPlaying) {
      _controller!.pause();
      widget.onPause?.call();
    } else {
      _controller!.play();
      widget.onPlay?.call();
    }
  }

  void _onPlayButtonTapped() {
    if (!_stateManager.isInitialized &&
        widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty) {
      _initializeVideo().then((_) {
        if (_stateManager.isInitialized && _controller != null) {
          _controller!.play();
          widget.onPlay?.call();
        }
      });
    } else {
      _togglePlayPause();
    }
  }

  void _seekTo(Duration position) {
    if (_controller == null || !_stateManager.isInitialized) return;
    _controller!.seekTo(position);
    widget.onSeek?.call(position);
  }

  double _getSliderValue() {
    if (_stateManager.totalDuration.inMilliseconds == 0) return 0.0;
    return _stateManager.currentPosition.inMilliseconds /
        _stateManager.totalDuration.inMilliseconds;
  }

  void _handleRetry() {
    setState(() {
      _stateManager.hasError = false;
      _stateManager.errorMessage = null;
    });
    _initializeVideo();
  }

  void _onSliderChanged(double value) {
    if (_controller == null || !_stateManager.isInitialized) return;
    setState(() {
      _stateManager.isSeeking = true;
    });
    final newPosition = Duration(
      milliseconds: (value * _stateManager.totalDuration.inMilliseconds)
          .round(),
    );
    _seekTo(newPosition);
  }

  void _onSliderChangeEnd() {
    setState(() {
      _stateManager.isSeeking = false;
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    if (widget.controller == null) {
      _stateManager.dispose();
    }
    super.dispose();
  }

  double _getAspectRatio() {
    if (_stateManager.isInitialized && _controller != null) {
      final size = _controller!.value.size;
      if (size.height > 0) {
        return size.width / size.height;
      }
    }
    return 16 / 9;
  }

  Widget _buildLayout(bool isFullScreen, double aspectRatio) {
    if (isFullScreen) {
      return VideoPlayerFullScreenLayout(
        aspectRatio: aspectRatio,
        isInitialized: _stateManager.isInitialized,
        isPlaying: _stateManager.isPlaying,
        hasError: _stateManager.hasError,
        errorMessage: _stateManager.errorMessage,
        controller: _controller,
        videoUrl: widget.videoUrl,
        thumbnailUrl: widget.thumbnailUrl,
        thumbnailImage: widget.thumbnailImage,
        currentPosition: _stateManager.currentPosition,
        totalDuration: _stateManager.totalDuration,
        sliderValue: _getSliderValue(),
        showMinimizeIcon: widget.showMinimizeIcon,
        onMinimize: widget.onMinimize,
        onSliderChanged: _onSliderChanged,
        onSliderChangeEnd: _onSliderChangeEnd,
        onPlayButtonTapped: _onPlayButtonTapped,
        onTogglePlayPause: _togglePlayPause,
        onRetry: _handleRetry,
      );
    }

    return VideoPlayerNormalLayout(
      aspectRatio: aspectRatio,
      isInitialized: _stateManager.isInitialized,
      isPlaying: _stateManager.isPlaying,
      hasError: _stateManager.hasError,
      errorMessage: _stateManager.errorMessage,
      controller: _controller,
      fullScreen: widget.fullScreen,
      videoUrl: widget.videoUrl,
      thumbnailUrl: widget.thumbnailUrl,
      thumbnailImage: widget.thumbnailImage,
      currentPosition: _stateManager.currentPosition,
      totalDuration: _stateManager.totalDuration,
      sliderValue: _getSliderValue(),
      showMinimizeIcon: widget.showMinimizeIcon,
      onMinimize: widget.onMinimize,
      onSliderChanged: _onSliderChanged,
      onSliderChangeEnd: _onSliderChangeEnd,
      onPlayButtonTapped: _onPlayButtonTapped,
      onRetry: _handleRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _getAspectRatio();
    final borderRadius = widget.fullScreen
        ? BorderRadius.zero
        : BorderRadius.circular(16.r);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AppColors.backgroundDark,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: _buildLayout(widget.fullScreen, aspectRatio),
      ),
    );
  }
}
