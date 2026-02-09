import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/helper_widgets/audio_player/audio_player_manager.dart';
import '../../../data/helper_widgets/device_service.dart';
import '../../../data/helper_widgets/video_player/video_player_manager.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class BottomBarController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupPointsListener();
    _loadPointsBalance();
    // Start device check
    _checkDevice();
    // Fallback: if check doesn't complete in 6 seconds, force it
    Future.delayed(const Duration(seconds: 6), () {
      if (isCheckingDevice.value) {
        isSamsungDevice.value = false;
        isCheckingDevice.value = false;
        update();
      }
    });
  }

  Future<void> _checkDevice() async {
    try {
      final isSamsung = await DeviceService.isSamsungDevice().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return false;
        },
      );
      // Update both values together to ensure consistency
      // Use update() to ensure reactive widgets rebuild
      isSamsungDevice.value = isSamsung;
      if (isSamsung == true) {
        debugPrint('trigger that fires when a pop-up is shown to a user whose device');
      }
      isCheckingDevice.value = false;
      update(); // Force update to ensure all reactive widgets rebuild
    } catch (e) {
      // On error, assume not Samsung and stop checking
      isSamsungDevice.value = false;
      isCheckingDevice.value = false;
      update(); // Force update to ensure all reactive widgets rebuild
      debugPrint(
        'BottomBarController: Error state - isSamsungDevice: ${isSamsungDevice.value}, isCheckingDevice: ${isCheckingDevice.value}',
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    _loadPointsBalance();
  }

  void increment() => count.value++;

  final RxInt currentIndex = 0.obs;
  final RxInt totalPoints = 0.obs;
  final RxBool isSamsungDevice = false.obs;
  final RxBool isCheckingDevice = true.obs;
  final List<String> _routeHistory = [Routes.HOME];

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
      final route = routes[index];
      if (!_routeHistory.contains(route)) {
        _routeHistory.add(route);
      }
      Get.toNamed(route, id: 1, preventDuplicates: false);
    }
  }

  String? getPreviousRoute() {
    if (_routeHistory.length > 1) {
      _routeHistory.removeLast();
      return _routeHistory.isNotEmpty ? _routeHistory.last : Routes.HOME;
    }
    return Routes.HOME;
  }

  void updateRouteHistory(String routeName) {
    if (_routeHistory.isEmpty || _routeHistory.last != routeName) {
      _routeHistory.add(routeName);
    }
  }

  void resetRouteHistory() {
    _routeHistory.clear();
    _routeHistory.add(Routes.HOME);
  }

  void _pauseAllMedia() {
    VideoPlayerManager.pauseAll();
    AudioPlayerManager.pauseAll();
  }

  void updateTotalPoints(int points) {
    totalPoints.value = points;
  }

  void updateCurrentIndexFromRouteName(String routeName) {
    final index = routes.indexWhere((route) => route == routeName);
    if (index != -1 && currentIndex.value != index) {
      currentIndex.value = index;
    }
  }
}
