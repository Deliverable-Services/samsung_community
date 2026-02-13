import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../skeleton_loader.dart';
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
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
          // Force LTR: start time left, end time right, progress bar left-to-right
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Start time — fixed on the left
                    if (widget.totalDuration.inSeconds == 0)
                      SkeletonLoader(
                        width: 40.w,
                        height: 14.h,
                        baseColor: Colors.white.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.4),
                        borderRadius: 4,
                      )
                    else
                      Text(
                        _formatDuration(widget.currentPosition),
                        style: TextStyle(
                          color: AppColors.accentBlueLight,
                          fontSize: 14.sp,
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    // End time — fixed on the right
                    if (widget.totalDuration.inSeconds == 0)
                      SkeletonLoader(
                        width: 40.w,
                        height: 14.h,
                        baseColor: Colors.white.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.4),
                        borderRadius: 4,
                      )
                    else
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
                  value: widget.sliderValue,
                  onChanged: (value) => widget.onSliderChanged?.call(value),
                  isEnabled: widget.isSliderEnabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
