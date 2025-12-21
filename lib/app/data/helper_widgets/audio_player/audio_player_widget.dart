import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'audio_player_controller_getx.dart';
import 'audio_player_layout.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String? audioUrl;
  final String? tag;

  const AudioPlayerWidget({super.key, this.audioUrl, this.tag});

  @override
  Widget build(BuildContext context) {
    final controllerTag = tag ?? audioUrl ?? 'audio_player';
    AudioPlayerControllerGetX controller;
    try {
      controller = Get.find<AudioPlayerControllerGetX>(tag: controllerTag);
      if (controller.audioUrl != audioUrl) {
        Get.delete<AudioPlayerControllerGetX>(tag: controllerTag);
        controller = Get.put(
          AudioPlayerControllerGetX(audioUrl: audioUrl),
          tag: controllerTag,
        );
      }
    } catch (_) {
      controller = Get.put(
        AudioPlayerControllerGetX(audioUrl: audioUrl),
        tag: controllerTag,
      );
    }

    return Obx(() {
      final isLoadingOrBuffering =
          controller.isLoading.value || controller.isBuffering.value;

      return AudioPlayerLayout(
        currentPosition: controller.currentPosition.value,
        totalDuration: controller.totalDuration.value,
        isPlaying: controller.isPlaying.value,
        isLoading: isLoadingOrBuffering,
        hasError: controller.hasError.value,
        onPlayPause: controller.togglePlayPause,
        sliderValue: controller.getSliderValue(),
        onSliderChanged: (isLoadingOrBuffering || controller.hasError.value)
            ? null
            : (value) {
                if (controller.totalDuration.value.inMilliseconds == 0) return;
                final seekPosition = Duration(
                  milliseconds:
                      (value * controller.totalDuration.value.inMilliseconds)
                          .round(),
                );
                controller.seekTo(seekPosition);
              },
        isSliderEnabled: !isLoadingOrBuffering && !controller.hasError.value,
      );
    });
  }
}
