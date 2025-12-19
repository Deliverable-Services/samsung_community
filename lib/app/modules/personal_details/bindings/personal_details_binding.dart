import 'package:get/get.dart';

import '../controllers/personal_details_controller.dart';

class PersonalDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PersonalDetailsController>()) {
      Get.lazyPut<PersonalDetailsController>(
        () => PersonalDetailsController(),
        fenix: true,
      );
    }
  }
}
