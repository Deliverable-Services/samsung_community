import 'package:get/get.dart';

import '../controllers/eventer_payment_controller.dart';

class EventerPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventerPaymentController>(
      () => EventerPaymentController(),
    );
  }
}
