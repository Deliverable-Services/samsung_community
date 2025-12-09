import 'package:get/get.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/personal_details_1.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  static Future? go(
    String routeName, {
    dynamic arguments,
    bool preventDuplicates = true,
  }) => Get.toNamed(
    routeName,
    arguments: arguments,
    preventDuplicates: preventDuplicates,
  );

  static void pop() => Get.back();

  static void pushAndRemoveUntil(String name, {dynamic arguments}) =>
      Get.offAllNamed(name, arguments: arguments);
}

class AppRouteName {
  static const String splashScreen = '/splash_screen',
      homeScreen = '/home_screen',
      welcomeScreen = '/welcome_screen',
      loginScreen = '/login_screen',
      signUpScreen = '/signup_screen',
      personalDetails1 = '/personal_details_1';

  static final List<GetPage<dynamic>> routes = [
    GetPage(name: welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(name: signUpScreen, page: () => const SignUpScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: personalDetails1, page: () => const PersonalDetails1Screen()),
  ];
}
