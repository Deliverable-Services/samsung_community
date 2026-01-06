import 'package:get/get.dart';

import '../controllers/followers_following_controller.dart';

class FollowersFollowingBinding extends Bindings {
  @override
  void dependencies() {
    final userId = Get.parameters['userId'] ?? 'current_user';
    Get.lazyPut<FollowersFollowingController>(
      () => FollowersFollowingController(),
      tag: userId,
    );
  }
}
