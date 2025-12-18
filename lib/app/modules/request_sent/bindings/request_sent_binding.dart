import 'package:get/get.dart';

import '../controllers/request_sent_controller.dart';

class RequestSentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestSentController>(
      () => RequestSentController(),
    );
  }
}
