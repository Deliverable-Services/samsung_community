import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_player_controller.dart' as audio_controller;
import 'audio_player_manager.dart';

class AudioPlayerControllerGetX extends GetxController {
  final String? audioUrl;

  late AudioPlayer _audioPlayer;
  late audio_controller.AudioPlayerController _audioController;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isInitializing = false.obs;
  final RxBool isPluginMissing = false.obs;
  final RxnString errorMessage = RxnString();

  AudioPlayerControllerGetX({this.audioUrl}) {
    _audioPlayer = AudioPlayer();
    _initializeController();
    _setupListeners();
  }

  void _initializeController() {
    _audioController = audio_controller.AudioPlayerController(
      audioPlayer: _audioPlayer,
      audioUrl: audioUrl,
      onError: (hasErr, errMsg) {
        hasError.value = hasErr;
        errorMessage.value = errMsg;
      },
      onLoadingChanged: (loading) {
        isLoading.value = loading;
      },
      onInitializedChanged: (initialized) {
        isInitialized.value = initialized;
      },
      onDurationChanged: (duration) {
        totalDuration.value = duration;
      },
    );
  }

  void _setupListeners() {
    _positionSubscription = _audioPlayer.positionStream.listen(
      (position) {
        currentPosition.value = position;
      },
      onError: (error) {
        final pluginMissing =
            error.toString().contains('MissingPluginException') ||
            error.toString().contains('No implementation found');
        hasError.value = true;
        isPluginMissing.value = pluginMissing;
        errorMessage.value = error.toString();
      },
    );

    _durationSubscription = _audioPlayer.durationStream.listen(
      (duration) {
        if (duration != null) {
          totalDuration.value = duration;
          if (!isInitialized.value && duration.inMilliseconds > 0) {
            isInitialized.value = true;
            isLoading.value = false;
          }
        }
      },
      onError: (error) {
        final pluginMissing =
            error.toString().contains('MissingPluginException') ||
            error.toString().contains('No implementation found');
        hasError.value = true;
        isPluginMissing.value = pluginMissing;
        errorMessage.value = error.toString();
      },
    );

    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (state) {
        final wasPlaying = isPlaying.value;
        isPlaying.value = state.playing;

        if (state.processingState == ProcessingState.loading &&
            isInitializing.value) {
          isLoading.value = true;
          isBuffering.value = false;
        } else if (state.processingState == ProcessingState.ready) {
          isLoading.value = false;
          isBuffering.value = false;
          isInitialized.value = true;
          isInitializing.value = false;
          hasError.value = false;
        } else if (state.processingState == ProcessingState.buffering) {
          isBuffering.value = true;
          isLoading.value = true;
        } else if (state.processingState == ProcessingState.idle) {
          if (!isInitializing.value) {
            isLoading.value = false;
            isBuffering.value = false;
          }
        }

        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
          AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
        }

        if (!wasPlaying && isPlaying.value && audioUrl != null) {
          AudioPlayerManager.setCurrentPlayer(_audioPlayer, audioUrl!);
        } else if (wasPlaying && !isPlaying.value) {
          AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
        }
      },
      onError: (error) {
        final pluginMissing =
            error.toString().contains('MissingPluginException') ||
            error.toString().contains('No implementation found');
        hasError.value = true;
        isPluginMissing.value = pluginMissing;
        errorMessage.value = error.toString();
        isLoading.value = false;
        isBuffering.value = false;
        isInitializing.value = false;
      },
    );
  }

  Future<void> initializeAudio() async {
    await _audioController.initializeAudio();
  }

  Future<void> togglePlayPause() async {
    await _audioController.togglePlayPause(
      isInitialized: isInitialized.value,
      isPlaying: isPlaying.value,
      hasError: hasError.value,
      onStateUpdate: () {
        isLoading.value = true;
      },
    );
  }

  void seekTo(Duration position) {
    _audioController.seekTo(position);
  }

  double getSliderValue() {
    if (totalDuration.value.inMilliseconds == 0) return 0.0;
    return currentPosition.value.inMilliseconds /
        totalDuration.value.inMilliseconds;
  }

  void reset() {
    _audioPlayer.stop();
    _audioPlayer.seek(Duration.zero);
    AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
    currentPosition.value = Duration.zero;
    totalDuration.value = Duration.zero;
    isPlaying.value = false;
    hasError.value = false;
    isInitialized.value = false;
    isLoading.value = false;
    isBuffering.value = false;
    isInitializing.value = false;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    AudioPlayerManager.clearCurrentPlayer(_audioPlayer);
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }
}

