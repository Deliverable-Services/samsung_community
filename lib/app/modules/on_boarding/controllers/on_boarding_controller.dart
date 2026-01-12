import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userData = {}.obs;

class OnBoardingController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;

  void clickOnSignUpWithGoogleButton() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('isGoogleLogin', true);
    Get.toNamed(Routes.SIGN_UP);
  }

  void clickOnLogInButton() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('isGoogleLogin', false);
    Get.toNamed(Routes.LOGIN);
  }
}
