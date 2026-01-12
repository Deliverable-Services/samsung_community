import 'package:get/get.dart';

import '../../verification_code/controllers/verification_code_controller.dart';
import '../controllers/login_options_controller.dart';

class LoginOptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginOptionsController>(
      () => LoginOptionsController(),
    );Get.lazyPut<VerificationCodeController>(
      () => VerificationCodeController(),
    );
  }
}
