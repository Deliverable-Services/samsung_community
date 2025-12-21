import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import 'audio_player_slider.dart';

class AudioPlayerLayout extends StatefulWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onPlayPause;
  final double sliderValue;
  final ValueChanged<double>? onSliderChanged;
  final bool isSliderEnabled;

  const AudioPlayerLayout({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.isLoading,
    required this.hasError,
    required this.onPlayPause,
    required this.sliderValue,
    this.onSliderChanged,
    this.isSliderEnabled = true,
  });

  @override
  State<AudioPlayerLayout> createState() => _AudioPlayerLayoutState();
}

class _AudioPlayerLayoutState extends State<AudioPlayerLayout> {
  final GlobalKey _sliderKey = GlobalKey();
  double _sliderWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSliderWidth();
    });
  }

  @override
  void didUpdateWidget(AudioPlayerLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliderValue != widget.sliderValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSliderWidth();
      });
    }
  }

  void _updateSliderWidth() {
    final RenderBox? renderBox =
        _sliderKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _sliderWidth = renderBox.size.width;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getCurrentTimePosition() {
    if (_sliderWidth == 0) return 0;
    final sliderValue = widget.sliderValue.clamp(0.0, 1.0);
    final thumbCenter = sliderValue * _sliderWidth;
    final currentTimeWidth = 50.0;
    final position = thumbCenter - (currentTimeWidth / 2);
    return position.clamp(0.0, _sliderWidth - currentTimeWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              GestureDetector(
                onTap: widget.isLoading ? null : widget.onPlayPause,
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: widget.hasError
                        ? Colors.grey
                        : AppColors.accentBlueLight,
                    shape: BoxShape.circle,
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : widget.isPlaying
                      ? Icon(Icons.pause, color: Colors.white, size: 18.sp)
                      : SvgPicture.asset(
                          AppImages.playIcon,
                          width: 18.w,
                          height: 18.h,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      Text(
                        _formatDuration(widget.totalDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  AudioPlayerSlider(
                    key: _sliderKey,
                    value: widget.sliderValue,
                    onChanged: (value) {
                      widget.onSliderChanged?.call(value);
                      _updateSliderWidth();
                    },
                    isEnabled: widget.isSliderEnabled,
                  ),
                ],
              ),
              Positioned(
                left: _getCurrentTimePosition(),
                top: 0,
                child: Text(
                  _formatDuration(widget.currentPosition),
                  style: TextStyle(
                    color: AppColors.accentBlueLight,
                    fontSize: 14.sp,
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
