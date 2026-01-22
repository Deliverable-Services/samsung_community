import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoThumbnailService {
  static final Map<String, String> _thumbnailCache = {};
  static final List<Future<void> Function()> _taskQueue = [];
  static bool _isProcessing = false;

  static Future<String?> generateThumbnail({
    required String videoUrl,
    int timeMs = 1000,
    int quality = 50,
  }) async {
    if (_thumbnailCache.containsKey(videoUrl)) {
      final cachedPath = _thumbnailCache[videoUrl];
      if (cachedPath != null && File(cachedPath).existsSync()) {
        return cachedPath;
      }
    }

    final completer = Completer<String?>();

    _taskQueue.add(() async {
      try {
        final tempDir = await getTemporaryDirectory();
        // Lower resolution and quality for performance
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoUrl,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300, // Reduced from 400
          quality: quality, // Reduced to 50 default
          timeMs: timeMs,
        );

        if (thumbnailPath != null && File(thumbnailPath).existsSync()) {
          _thumbnailCache[videoUrl] = thumbnailPath;
          completer.complete(thumbnailPath);
        } else {
          completer.complete(null);
        }
      } catch (e) {
        if (!e.toString().contains('MissingPluginException')) {
           debugPrint('Error generating video thumbnail for $videoUrl: $e');
        }
        completer.complete(null);
      }
    });

    _processQueue();

    return completer.future;
  }

  static Future<void> _processQueue() async {
    if (_isProcessing || _taskQueue.isEmpty) return;
    _isProcessing = true;

    try {
      while (_taskQueue.isNotEmpty) {
        final task = _taskQueue.removeAt(0);
        await task();
        // Small delay to allow UI to breathe
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      _isProcessing = false;
    }
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

