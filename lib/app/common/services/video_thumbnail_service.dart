import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoThumbnailService {
  static final Map<String, String> _thumbnailCache = {};

  static Future<String?> generateThumbnail({
    required String videoUrl,
    int timeMs = 1000,
    int quality = 75,
  }) async {
    if (_thumbnailCache.containsKey(videoUrl)) {
      final cachedPath = _thumbnailCache[videoUrl];
      if (cachedPath != null && File(cachedPath).existsSync()) {
        return cachedPath;
      }
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: quality,
        timeMs: timeMs,
      );

      if (thumbnailPath != null && File(thumbnailPath).existsSync()) {
        _thumbnailCache[videoUrl] = thumbnailPath;
        return thumbnailPath;
      }
    } catch (e) {
      // Handle MissingPluginException and other errors gracefully
      debugPrint('Error generating video thumbnail for $videoUrl: $e');
      // Don't cache failed attempts to allow retry
    }

    return null;
  }

  static void clearCache() {
    for (final thumbnailPath in _thumbnailCache.values) {
      try {
        final file = File(thumbnailPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('Error deleting thumbnail cache: $e');
      }
    }
    _thumbnailCache.clear();
  }

  static void clearCacheForVideo(String videoUrl) {
    final thumbnailPath = _thumbnailCache.remove(videoUrl);
    if (thumbnailPath != null) {
      try {
        final file = File(thumbnailPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('Error deleting thumbnail cache: $e');
      }
    }
  }
}

