import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_images.dart';
import 'video_player_thumbnail_controller.dart';
import 'package:flutter_svg/svg.dart';

class VideoPlayerThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final String? videoUrl;

  const VideoPlayerThumbnail({
    super.key,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controllerTag =
        'thumbnail_${videoUrl ?? thumbnailUrl ?? thumbnailImage ?? 'default'}';

    VideoPlayerThumbnailController controller;
    try {
      controller = Get.find<VideoPlayerThumbnailController>(tag: controllerTag);
      // Update controller if URLs changed
      if (controller.videoUrl != videoUrl ||
          controller.thumbnailUrl != thumbnailUrl ||
          controller.thumbnailImage != thumbnailImage) {
        Get.delete<VideoPlayerThumbnailController>(tag: controllerTag);
        controller = Get.put(
          VideoPlayerThumbnailController(
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            thumbnailImage: thumbnailImage,
          ),
          tag: controllerTag,
        );
      }
    } catch (_) {
      controller = Get.put(
        VideoPlayerThumbnailController(
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          thumbnailImage: thumbnailImage,
        ),
        tag: controllerTag,
      );
    }

    // Check non-reactive properties first
    if (controller.thumbnailUrl != null) {
      return _buildThumbnailImage(controller.thumbnailUrl!);
    }

    if (controller.thumbnailImage != null) {
      return _buildThumbnailImage(controller.thumbnailImage!);
    }

    // Generation logic is handled in the controller's onInit or onReady
    // if (controller.shouldGenerateThumbnail()) {
    //    controller.generateThumbnail();
    // }

    // Use Obx only for reactive variables
    return Obx(() {
      if (controller.generatedThumbnailPath.value != null) {
        return _buildThumbnailImage(controller.generatedThumbnailPath.value!);
      }

      if (controller.isGenerating.value) {
        return Container(
          color: const Color(0xFF2A2A2A),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      // Fallback: Show app logo when thumbnail generation fails
      return _buildAppLogoFallback();
    });
  }

  Widget _buildThumbnailImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 600,
        maxWidthDiskCache: 600,
        placeholder: (context, url) => Container(
          color: const Color(0xFF2A2A2A),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          return _buildAppLogoFallback();
        },
      );
    } else if (url.startsWith('/') || url.contains('\\')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildAppLogoFallback();
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildAppLogoFallback();
        },
      );
    }
  }

  Widget _buildAppLogoFallback() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: SvgPicture.asset(
          AppImages.logo,
          fit: BoxFit.contain,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: const Color(0xFF2A2A2A));
          },
        ),
      ),
    );
  }
}
