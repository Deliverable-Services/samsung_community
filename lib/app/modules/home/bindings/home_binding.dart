import 'package:get/get.dart';

import '../../events/controllers/events_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Register EventsController for reuse in home view
    Get.lazyPut<EventsController>(
      () => EventsController(),
      fenix: true,
    );
  }
}
