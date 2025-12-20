import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import 'video_player_slider.dart';

class MediaSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeEnd;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final bool isEnabled;

  const MediaSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultActiveColor = activeTrackColor ?? AppColors.accentBlueLight;
    final defaultInactiveColor = inactiveTrackColor ?? AppColors.backgroundGrey;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.h,
        activeTrackColor: defaultActiveColor,
        inactiveTrackColor: defaultInactiveColor,
        trackShape: CustomTrackShape(),
        thumbShape: CustomSliderThumb(
          thumbRadius: 6.r,
          borderWidth: 4.w,
        ),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
      ),
      child: Slider(
        value: value.clamp(0.0, 1.0),
        onChanged: isEnabled ? onChanged : null,
        onChangeEnd: onChangeEnd != null ? (_) => onChangeEnd!() : null,
      ),
    );
  }
}

