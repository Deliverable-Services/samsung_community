import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'video_modal.dart';

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

class _CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double borderWidth;

  const _CustomSliderThumb({
    required this.thumbRadius,
    required this.borderWidth,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius + borderWidth);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final bluePaint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius + borderWidth, bluePaint);

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, whitePaint);
  }
}

class _CustomTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2.0;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Canvas canvas = context.canvas;
    final trackHeight = sliderTheme.trackHeight ?? 2.0;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey
      ..style = PaintingStyle.fill;
    final inactiveRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );
    final inactiveRadius = Radius.circular(trackHeight / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveRect, inactiveRadius),
      inactivePaint,
    );

    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    final activeRadius = Radius.circular(trackHeight / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, activeRadius),
      activePaint,
    );
  }
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isSeeking = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      _controller = widget.controller;
      _isInitialized = true;
      _totalDuration = _controller!.value.duration;
      _currentPosition = _controller!.value.position;
      _isPlaying = _controller!.value.isPlaying;
      _controller!.addListener(_videoListener);
    } else {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return;
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));

    try {
      await _controller!.initialize();
      _controller!.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _totalDuration = _controller!.value.duration;
          _currentPosition = _controller!.value.position;
          _isPlaying = _controller!.value.isPlaying;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    if (!_isSeeking && mounted) {
      setState(() {
        _currentPosition = _controller!.value.position;
        _totalDuration = _controller!.value.duration;
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() async {
    if (!_isInitialized) {
      if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;
      await _initializeVideo();
      if (_isInitialized && _controller != null) {
        _controller!.play();
        widget.onPlay?.call();
        return;
      }
      return;
    }

    if (_controller == null) return;

    if (_isPlaying) {
      _controller!.pause();
      widget.onPause?.call();
    } else {
      _controller!.play();
      widget.onPlay?.call();
    }
  }

  void _seekTo(Duration position) {
    if (_controller == null || !_isInitialized) return;
    _controller!.seekTo(position);
    widget.onSeek?.call(position);
  }

  double _getSliderValue() {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  double _getAspectRatio() {
    if (_isInitialized && _controller != null) {
      final size = _controller!.value.size;
      if (size.height > 0) {
        return size.width / size.height;
      }
    }
    return 16 / 9;
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _getAspectRatio();

    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.fullScreen
            ? BorderRadius.zero
            : BorderRadius.circular(16.r),
        color: AppColors.backgroundDark,
      ),
      child: ClipRRect(
        borderRadius: widget.fullScreen
            ? BorderRadius.zero
            : BorderRadius.circular(16.r),
        child: widget.fullScreen
            ? _buildFullScreenLayout(aspectRatio)
            : _buildNormalLayout(aspectRatio),
      ),
    );
  }

  Widget _buildNormalLayout(double aspectRatio) {
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
                    if (_isInitialized && _controller != null)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDarkMedium,
                        ),
                        child:
                            (widget.thumbnailUrl != null ||
                                widget.thumbnailImage != null)
                            ? Image.asset(
                                widget.thumbnailUrl ?? widget.thumbnailImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Container(color: const Color(0xFF2A2A2A)),
                      ),
                    if (!_isPlaying || !_isInitialized)
                      Center(
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 80.w,
                            height: 80.h,
                            child: Center(
                              child: Image.asset(
                                AppImages.playButton,
                                width: 62.w,
                                height: 62.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isPlaying && _isInitialized)
                      GestureDetector(
                        onTap: _togglePlayPause,
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: AppColors.backgroundDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '/${_formatDuration(_totalDuration)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.showMinimizeIcon
                        ? widget.onMinimize
                        : () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) => VideoModal(
                                  videoUrl: widget.videoUrl,
                                  thumbnailUrl: widget.thumbnailUrl,
                                  thumbnailImage: widget.thumbnailImage,
                                  controller: _controller,
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                    child: Image.asset(
                      widget.showMinimizeIcon
                          ? AppImages.minimizeIcon
                          : AppImages.maximizeIcon,
                      width: 20.w,
                      height: 20.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4.h,
                  activeTrackColor: AppColors.accentBlueLight,
                  inactiveTrackColor: AppColors.backgroundGrey,
                  trackShape: _CustomTrackShape(),
                  thumbShape: _CustomSliderThumb(
                    thumbRadius: 6.r,
                    borderWidth: 4.w,
                  ),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                ),
                child: Slider(
                  value: _getSliderValue().clamp(0.0, 1.0),
                  onChanged: (value) {
                    if (_controller == null || !_isInitialized) return;
                    setState(() {
                      _isSeeking = true;
                    });
                    final newPosition = Duration(
                      milliseconds: (value * _totalDuration.inMilliseconds)
                          .round(),
                    );
                    _seekTo(newPosition);
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      _isSeeking = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenLayout(double aspectRatio) {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                if (_isInitialized && _controller != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFF2A2A2A)),
                    child:
                        (widget.thumbnailUrl != null ||
                            widget.thumbnailImage != null)
                        ? Image.asset(
                            widget.thumbnailUrl ?? widget.thumbnailImage!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Container(color: const Color(0xFF2A2A2A)),
                  ),
                if (!_isPlaying || !_isInitialized)
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentBlue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 25.r,
                              spreadRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 45.sp,
                        ),
                      ),
                    ),
                  ),
                if (_isPlaying && _isInitialized)
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
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
                    Row(
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: 'Samsung Sharp Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '/${_formatDuration(_totalDuration)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: 'Samsung Sharp Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    if (widget.showMinimizeIcon && widget.onMinimize != null)
                      GestureDetector(
                        onTap: widget.onMinimize,
                        child: Image.asset(
                          AppImages.minimizeIcon,
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.h,
                    activeTrackColor: const Color(0xFF8CB5FF),
                    inactiveTrackColor: const Color(0xFF4A4A4A),
                    trackShape: _CustomTrackShape(),
                    thumbShape: _CustomSliderThumb(
                      thumbRadius: 6.r,
                      borderWidth: 4.w,
                    ),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                  ),
                  child: Slider(
                    value: _getSliderValue().clamp(0.0, 1.0),
                    onChanged: (value) {
                      if (_controller == null || !_isInitialized) return;
                      setState(() {
                        _isSeeking = true;
                      });
                      final newPosition = Duration(
                        milliseconds: (value * _totalDuration.inMilliseconds)
                            .round(),
                      );
                      _seekTo(newPosition);
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        _isSeeking = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
