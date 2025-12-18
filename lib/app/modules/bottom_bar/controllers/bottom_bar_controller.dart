import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

class BottomBarController extends GetxController {
  //TODO: Implement BottomBarController

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  final RxInt currentIndex = 0.obs;
  final RxInt totalPoints = 124.obs;

  // Route names for each tab
  final List<String> routes = [
    Routes.HOME,
    Routes.VOD,
    Routes.ACADEMY,
    Routes.FEED,
    Routes.EVENTS,
  ];

  void changeTab(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      Get.offNamed(routes[index], id: 1);
    }
  }

  void updateTotalPoints(int points) {
    totalPoints.value = points;
  }
}
