import 'package:get/get.dart';

import '../controllers/academy_controller.dart';

class AcademyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AcademyController>(
      () => AcademyController(),
    );
  }
}
