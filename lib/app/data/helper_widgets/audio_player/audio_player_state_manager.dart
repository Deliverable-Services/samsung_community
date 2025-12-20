import 'dart:async';
import 'package:just_audio/just_audio.dart';

import 'audio_player_manager.dart';

class AudioPlayerStateManager {
  final AudioPlayer audioPlayer;
  final String? audioUrl;
  final Function(Duration) onPositionChanged;
  final Function(Duration) onDurationChanged;
  final Function(bool) onPlayingChanged;
  final Function(bool) onLoadingChanged;
  final Function(bool) onInitializedChanged;
  final Function(bool, String?) onErrorChanged;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;
  bool isBuffering = false;
  bool isInitialized = false;
  bool hasError = false;
  bool isInitializing = false;
  bool isPluginMissing = false;
  String? errorMessage;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioPlayerStateManager({
    required this.audioPlayer,
    required this.audioUrl,
    required this.onPositionChanged,
    required this.onDurationChanged,
    required this.onPlayingChanged,
    required this.onLoadingChanged,
    required this.onInitializedChanged,
    required this.onErrorChanged,
  });

  void setupListeners() {
    _positionSubscription = audioPlayer.positionStream.listen(
      (position) {
        currentPosition = position;
        onPositionChanged(position);
      },
      onError: (error) {
        final isPluginMissing =
            error.toString().contains('MissingPluginException') ||
            error.toString().contains('No implementation found');
        hasError = true;
        this.isPluginMissing = isPluginMissing;
        errorMessage = error.toString();
        onErrorChanged(true, error.toString());
      },
    );

    _durationSubscription = audioPlayer.durationStream.listen(
      (duration) {
        if (duration != null) {
          totalDuration = duration;
          onDurationChanged(duration);
          if (!isInitialized && duration.inMilliseconds > 0) {
            isInitialized = true;
            isLoading = false;
            onInitializedChanged(true);
            onLoadingChanged(false);
          }
        }
      },
      onError: (error) {
        final isPluginMissing =
            error.toString().contains('MissingPluginException') ||
            error.toString().contains('No implementation found');
        hasError = true;
        this.isPluginMissing = isPluginMissing;
        errorMessage = error.toString();
        onErrorChanged(true, error.toString());
      },
    );

    _playerStateSubscription = audioPlayer.playerStateStream.listen(
      (state) {
        final wasPlaying = isPlaying;
        isPlaying = state.playing;

        if (state.processingState == ProcessingState.loading &&
            isInitializing) {
          isLoading = true;
          isBuffering = false;
          onLoadingChanged(true);
        } else if (state.processingState == ProcessingState.ready) {
          isLoading = false;
          isBuffering = false;
          isInitialized = true;
          isInitializing = false;
          hasError = false;
          onLoadingChanged(false);
          onInitializedChanged(true);
        } else if (state.processingState == ProcessingState.buffering) {
          isBuffering = true;
          isLoading = true;
          onLoadingChanged(true);
        } else if (state.processingState == ProcessingState.idle) {
          if (!isInitializing) {
            isLoading = false;
            isBuffering = false;
            onLoadingChanged(false);
          }
        }

        if (state.processingState == ProcessingState.completed) {
          isPlaying = false;
          AudioPlayerManager.clearCurrentPlayer(audioPlayer);
        }

        onPlayingChanged(isPlaying);

        if (!wasPlaying && isPlaying && audioUrl != null) {
          AudioPlayerManager.setCurrentPlayer(audioPlayer, audioUrl!);
        } else if (wasPlaying && !isPlaying) {
          AudioPlayerManager.clearCurrentPlayer(audioPlayer);
        }
      },
      onError: (error) {
        final isPluginMissing =
            error.toString().contains('MissingPluginException') ||
            error.toString().contains('No implementation found');
        hasError = true;
        this.isPluginMissing = isPluginMissing;
        errorMessage = error.toString();
        isLoading = false;
        isBuffering = false;
        isInitializing = false;
        onErrorChanged(true, error.toString());
        onLoadingChanged(false);
      },
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
  }

  void reset() {
    currentPosition = Duration.zero;
    totalDuration = Duration.zero;
    isPlaying = false;
    isLoading = false;
    isBuffering = false;
    isInitialized = false;
    hasError = false;
    isInitializing = false;
    errorMessage = null;
  }
}
