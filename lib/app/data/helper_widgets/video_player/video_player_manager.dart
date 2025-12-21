import 'package:video_player/video_player.dart' as video_player;

class VideoPlayerManager {
  static video_player.VideoPlayerController? _currentController;

  static void setCurrentPlayer(
    video_player.VideoPlayerController controller,
    String videoUrl,
  ) {
    if (_currentController != null && _currentController != controller) {
      try {
        if (_currentController!.value.isInitialized &&
            _currentController!.value.isPlaying) {
          _currentController!.pause();
        }
      } catch (_) {}
    }
    _currentController = controller;
  }

  static void clearCurrentPlayer(video_player.VideoPlayerController controller) {
    if (_currentController == controller) {
      _currentController = null;
    }
  }

  static void pauseAll() {
    if (_currentController != null) {
      try {
        if (_currentController!.value.isInitialized &&
            _currentController!.value.isPlaying) {
          _currentController!.pause();
        }
      } catch (_) {}
      _currentController = null;
    }
  }
}

