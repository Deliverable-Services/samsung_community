import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  static AudioPlayer? _currentPlayer;

  static void setCurrentPlayer(AudioPlayer player, String audioUrl) {
    if (_currentPlayer != null && _currentPlayer != player) {
      _currentPlayer?.pause();
      _currentPlayer?.stop();
    }
    _currentPlayer = player;
  }

  static void clearCurrentPlayer(AudioPlayer player) {
    if (_currentPlayer == player) {
      _currentPlayer = null;
    }
  }

  static void pauseAll() {
    if (_currentPlayer != null) {
      try {
        _currentPlayer?.pause();
        _currentPlayer?.stop();
      } catch (_) {}
      _currentPlayer = null;
    }
  }
}
