import 'package:get/get.dart';

import '../controllers/bottom_bar_controller.dart';
import '../../vod/controllers/vod_controller.dart';

class BottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomBarController>(() => BottomBarController());
    Get.lazyPut<VodController>(() => VodController(), fenix: true);
  }
}
