import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    final userId = Get.parameters['userId'] ?? 'unknown_user';
    Get.lazyPut<UserProfileController>(
      () => UserProfileController(),
      tag: userId,
    );
  }
}
