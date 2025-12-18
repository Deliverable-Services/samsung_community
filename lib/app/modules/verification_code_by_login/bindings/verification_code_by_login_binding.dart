import 'package:get/get.dart';

import '../controllers/verification_code_by_login_controller.dart';

class VerificationCodeByLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerificationCodeByLoginController>(
      () => VerificationCodeByLoginController(),
    );
  }
}
