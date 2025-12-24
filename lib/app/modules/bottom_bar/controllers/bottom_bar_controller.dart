import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/helper_widgets/audio_player/audio_player_manager.dart';
import '../../../data/helper_widgets/video_player/video_player_manager.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class BottomBarController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupPointsListener();
    _loadPointsBalance();
  }

  @override
  void onReady() {
    super.onReady();
    _loadPointsBalance();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  final RxInt currentIndex = 0.obs;
  final RxInt totalPoints = 0.obs;

  void _loadPointsBalance() {
    try {
      final authRepo = Get.find<AuthRepo>();
      if (authRepo.currentUser.value != null) {
        totalPoints.value = authRepo.currentUser.value!.pointsBalance;
      }
    } catch (e) {
      print('Error loading points balance: $e');
    }
  }

  void _setupPointsListener() {
    try {
      final authRepo = Get.find<AuthRepo>();
      ever(authRepo.currentUser, (user) {
        if (user != null) {
          totalPoints.value = user.pointsBalance;
        }
      });
    } catch (e) {
      print('Error setting up points listener: $e');
    }
  }

  // Route names for each tab
  final List<String> routes = [
    Routes.HOME,
    Routes.VOD,
    Routes.ACADEMY,
    Routes.FEED,
    Routes.EVENTS,
  ];

  void changeTab(int index, bool isBottomBar) {
    if (!isBottomBar) {
      Get.back();
    }
    if (currentIndex.value != index) {
      _pauseAllMedia();
      currentIndex.value = index;
      Get.offNamed(routes[index], id: 1);
    }
  }

  void _pauseAllMedia() {
    VideoPlayerManager.pauseAll();
    AudioPlayerManager.pauseAll();
  }

  void updateTotalPoints(int points) {
    totalPoints.value = points;
  }
}
