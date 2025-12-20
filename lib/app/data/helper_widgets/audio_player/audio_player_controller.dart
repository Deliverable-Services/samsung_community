import 'dart:async';
import 'package:just_audio/just_audio.dart';

import 'audio_player_manager.dart';

class AudioPlayerController {
  final AudioPlayer audioPlayer;
  final String? audioUrl;
  final Function(bool, String?) onError;
  final Function(bool) onLoadingChanged;
  final Function(bool) onInitializedChanged;
  final Function(Duration) onDurationChanged;

  bool isInitializing = false;
  bool isPluginMissing = false;

  AudioPlayerController({
    required this.audioPlayer,
    required this.audioUrl,
    required this.onError,
    required this.onLoadingChanged,
    required this.onInitializedChanged,
    required this.onDurationChanged,
  });

  Future<void> initializeAudio() async {
    if (isInitializing || isPluginMissing) return;

    if (audioUrl == null || audioUrl!.isEmpty) {
      onError(true, 'No audio URL provided');
      return;
    }

    isInitializing = true;
    onLoadingChanged(true);
    onError(false, null);

    try {
      await audioPlayer
          .setUrl(audioUrl!)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Audio loading timeout');
            },
          );

      await Future.delayed(const Duration(milliseconds: 500));

      final duration = audioPlayer.duration;
      if (duration != null && duration.inMilliseconds > 0) {
        isInitializing = false;
        onInitializedChanged(true);
        onLoadingChanged(false);
        onDurationChanged(duration);
      } else {
        await audioPlayer.durationStream.first
            .timeout(const Duration(seconds: 5), onTimeout: () => null)
            .then((duration) {
              if (duration != null && duration.inMilliseconds > 0) {
                isInitializing = false;
                onInitializedChanged(true);
                onLoadingChanged(false);
                onDurationChanged(duration);
              } else {
                isInitializing = false;
                onLoadingChanged(false);
                onError(true, 'Failed to get audio duration');
              }
            })
            .catchError((e) {
              isInitializing = false;
              onLoadingChanged(false);
              onError(true, 'Failed to get audio duration');
            });
      }
    } catch (e) {
      final isPluginMissing =
          e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found');

      this.isPluginMissing = isPluginMissing;
      isInitializing = false;
      onLoadingChanged(false);
      onError(
        true,
        isPluginMissing
            ? 'Audio plugin not available. Please rebuild the app.'
            : e.toString(),
      );
    }
  }

  Future<void> togglePlayPause({
    required bool isInitialized,
    required bool isPlaying,
    required bool hasError,
    required Function() onStateUpdate,
  }) async {
    if (isPluginMissing) {
      return;
    }

    if (!isInitialized) {
      if (audioUrl == null || audioUrl!.isEmpty) {
        onError(true, 'No audio URL provided');
        return;
      }

      onStateUpdate();
      await initializeAudio();

      if (!hasError && !isPluginMissing) {
        try {
          AudioPlayerManager.setCurrentPlayer(audioPlayer, audioUrl!);
          await audioPlayer.play();
        } catch (e) {
          onError(true, 'Failed to play audio: ${e.toString()}');
          onLoadingChanged(false);
        }
      } else {
        onLoadingChanged(false);
      }
      return;
    }

    try {
      if (isPlaying) {
        await audioPlayer.pause();
        AudioPlayerManager.clearCurrentPlayer(audioPlayer);
      } else {
        AudioPlayerManager.setCurrentPlayer(audioPlayer, audioUrl!);
        await audioPlayer.play();
      }
    } catch (e) {
      onError(true, 'Failed to control playback: ${e.toString()}');
    }
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }
}
