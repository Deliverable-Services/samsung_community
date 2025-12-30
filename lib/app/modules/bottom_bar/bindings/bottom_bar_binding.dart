import 'package:get/get.dart';

import '../controllers/bottom_bar_controller.dart';
import '../../vod/controllers/vod_controller.dart';

class BottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BottomBarController>(BottomBarController(), permanent: true);
    Get.lazyPut<VodController>(() => VodController(), fenix: true);
  }
}
