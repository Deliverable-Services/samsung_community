import 'package:get/get.dart';

import '../controllers/account_detail_controller.dart';

class AccountDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AccountDetailController>()) {
      Get.lazyPut<AccountDetailController>(
        () => AccountDetailController(),
        fenix: true,
      );
    }
  }
}
