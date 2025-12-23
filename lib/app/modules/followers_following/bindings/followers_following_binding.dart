import 'package:get/get.dart';

import '../controllers/followers_following_controller.dart';

class FollowersFollowingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowersFollowingController>(
      () => FollowersFollowingController(),
    );
  }
}
