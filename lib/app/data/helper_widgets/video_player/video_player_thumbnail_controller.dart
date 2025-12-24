import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    if (_shouldGenerateThumbnail()) {
      _generateThumbnail();
    }
  }

  bool _shouldGenerateThumbnail() {
    return (thumbnailUrl == null && thumbnailImage == null) &&
        videoUrl != null &&
        videoUrl!.isNotEmpty;
  }

  Future<void> _generateThumbnail() async {
    if (videoUrl == null || videoUrl!.isEmpty) return;

    isGenerating.value = true;

    try {
      final thumbnailPath = await VideoThumbnailService.generateThumbnail(
        videoUrl: videoUrl!,
        timeMs: 1000,
        quality: 75,
      );

      if (thumbnailPath != null) {
        generatedThumbnailPath.value = thumbnailPath;
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
    } finally {
      isGenerating.value = false;
    }
  }
}

