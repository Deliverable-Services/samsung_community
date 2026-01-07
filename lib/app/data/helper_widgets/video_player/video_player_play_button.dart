import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class VideoPlayerPlayButton extends StatelessWidget {
  final bool fullScreen;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isBuffering;

  const VideoPlayerPlayButton({
    super.key,
    required this.fullScreen,
    required this.onTap,
    this.isLoading = false,
    this.isBuffering = false,
  });

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      strokeWidth: 3,
    );
  }

  Widget _buildPlayIcon() {
    if (fullScreen) {
      return Icon(Icons.play_arrow, color: Colors.white, size: 45.sp);
    }
    return Image.asset(AppImages.playButton, width: 62.w, height: 62.w);
  }

  @override
  Widget build(BuildContext context) {
    final showLoading = isLoading || isBuffering;

    if (fullScreen) {
      return Center(
        child: GestureDetector(
          onTap: showLoading ? null : onTap,
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
            child: showLoading ? _buildLoadingIndicator() : _buildPlayIcon(),
          ),
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: showLoading ? null : onTap,
        child: SizedBox(
          width: 80.w,
          height: 80.h,
          child: Center(
            child: showLoading ? _buildLoadingIndicator() : _buildPlayIcon(),
          ),
        ),
      ),
    );
  }
}
