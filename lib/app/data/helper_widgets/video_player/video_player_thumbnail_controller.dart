import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../common/services/video_thumbnail_service.dart';

class VideoPlayerThumbnailController extends GetxController {
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;

  VideoPlayerThumbnailController({
    this.videoUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
  });

  final RxnString generatedThumbnailPath = RxnString();
  final RxBool isGenerating = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    // Debounce generation to avoid lag during fast scrolling
    if (shouldGenerateThumbnail()) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          generateThumbnail();
        }
      });
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  bool shouldGenerateThumbnail() {
    return (thumbnailUrl == null && thumbnailImage == null) &&
        videoUrl != null &&
        videoUrl!.isNotEmpty;
  }

  Future<void> generateThumbnail() async {
    if (videoUrl == null || videoUrl!.isEmpty) return;
    // Check if already generated or generating
    if (generatedThumbnailPath.value != null || isGenerating.value) return;

    isGenerating.value = true;

    try {
      final thumbnailPath = await VideoThumbnailService.generateThumbnail(
        videoUrl: videoUrl!,
        timeMs: 1000,
        quality: 50,
      );

      if (thumbnailPath != null) {
        generatedThumbnailPath.value = thumbnailPath;
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    } finally {
      isGenerating.value = false;
    }
  }
}

