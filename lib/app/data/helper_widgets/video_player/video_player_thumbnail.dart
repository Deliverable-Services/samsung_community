import 'package:flutter/material.dart';

class VideoPlayerThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final String? thumbnailImage;

  const VideoPlayerThumbnail({
    super.key,
    this.thumbnailUrl,
    this.thumbnailImage,
  });

  Widget _buildThumbnailImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFF2A2A2A));
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl == null && thumbnailImage == null) {
      return Container(color: const Color(0xFF2A2A2A));
    }

    return _buildThumbnailImage(thumbnailUrl ?? thumbnailImage!);
  }
}

