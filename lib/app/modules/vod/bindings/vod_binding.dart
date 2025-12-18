import 'package:get/get.dart';

import '../controllers/vod_controller.dart';

class VodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VodController>(
      () => VodController(),
    );
  }
}
