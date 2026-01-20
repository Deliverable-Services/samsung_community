import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import 'package:just_audio/just_audio.dart';

class MediaDurationService {
  static final Map<String, Duration> _cache = {};
  static final List<_DurationRequest> _queue = [];
  static bool _isProcessing = false;

  static Future<Duration?> getDuration(String url, {bool isAudio = false}) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    final completer = Completer<Duration?>();
    _queue.add(_DurationRequest(url, completer, isAudio: isAudio));
    _processQueue();

    return completer.future;
  }

  static Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    final request = _queue.removeAt(0);

    try {
      if (_cache.containsKey(request.url)) {
        request.completer.complete(_cache[request.url]);
      } else {
        Duration? duration;
        if (request.isAudio) {
           final player = AudioPlayer();
           try {
             duration = await player.setUrl(request.url);
           } finally {
             await player.dispose();
           }
        } else {
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(request.url),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );

          await controller.initialize().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Duration fetch timeout');
            },
          );
          duration = controller.value.duration;
          await controller.dispose();
        }

        if (duration != null) {
          _cache[request.url] = duration;
          request.completer.complete(duration);
        } else {
           request.completer.complete(null);
        }
      }
    } catch (e) {
      debugPrint('Error fetching duration for ${request.url}: $e');
      request.completer.complete(null);
    } finally {
      _isProcessing = false;
      await Future.delayed(const Duration(milliseconds: 100));
      _processQueue();
    }
  }
}

class _DurationRequest {
  final String url;
  final Completer<Duration?> completer;
  final bool isAudio;

  _DurationRequest(this.url, this.completer, {this.isAudio = false});
}
