import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/helper_widgets/video_player/video_player_widget.dart';

class FeedCardMedia extends StatelessWidget {
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String contentId;

  const FeedCardMedia({
    super.key,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.contentId,
  });

  bool get _isVideo {
    if (mediaUrl == null) return false;
    final url = mediaUrl!.toLowerCase();
    return url.contains('.mp4') ||
        url.contains('.mov') ||
        url.contains('.avi') ||
        url.contains('video');
  }

  @override
  Widget build(BuildContext context) {
    if (mediaUrl == null || mediaUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: VideoPlayerWidget(
          videoUrl: mediaUrl!,
          thumbnailUrl: thumbnailUrl,
          tag: 'feed_$contentId',
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: mediaUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(
          height: 200.h,
          color: AppColors.backgroundDark,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200.h,
          color: AppColors.backgroundDark,
          child: Icon(
            Icons.image_not_supported,
            size: 48.sp,
            color: AppColors.textWhiteOpacity60,
          ),
        ),
      ),
    );
  }
}
