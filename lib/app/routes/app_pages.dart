import 'package:get/get.dart';

import '../modules/academy/bindings/academy_binding.dart';
import '../modules/academy/views/academy_view.dart';
import '../modules/bottom_bar/bindings/bottom_bar_binding.dart';
import '../modules/bottom_bar/views/bottom_bar_view.dart';
import '../modules/events/bindings/events_binding.dart';
import '../modules/events/views/events_view.dart';
import '../modules/feed/bindings/feed_binding.dart';
import '../modules/feed/views/feed_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/on_boarding/bindings/on_boarding_binding.dart';
import '../modules/on_boarding/views/on_boarding_view.dart';
import '../modules/personal_details/bindings/personal_details_binding.dart';
import '../modules/personal_details/views/personal_details_view.dart';
import '../modules/sign_up/bindings/sign_up_binding.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/verification_code/bindings/verification_code_binding.dart';
import '../modules/verification_code/views/verification_code_view.dart';
import '../modules/verification_code_by_login/bindings/verification_code_by_login_binding.dart';
import '../modules/verification_code_by_login/views/verification_code_by_login_view.dart';
import '../modules/vod/bindings/vod_binding.dart';
import '../modules/vod/views/vod_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.ON_BOARDING,
      page: () => const OnBoardingView(),
      binding: OnBoardingBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM_BAR,
      page: () => const BottomBarView(),
      binding: BottomBarBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION_CODE,
      page: () => const VerificationCodeView(),
      binding: VerificationCodeBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION_CODE_BY_LOGIN,
      page: () => const VerificationCodeByLoginView(),
      binding: VerificationCodeByLoginBinding(),
    ),
    GetPage(
      name: _Paths.VOD,
      page: () => const VodView(),
      binding: VodBinding(),
    ),
    GetPage(
      name: _Paths.ACADEMY,
      page: () => const AcademyView(),
      binding: AcademyBinding(),
    ),
    GetPage(
      name: _Paths.FEED,
      page: () => const FeedView(),
      binding: FeedBinding(),
    ),
    GetPage(
      name: _Paths.EVENTS,
      page: () => const EventsView(),
      binding: EventsBinding(),
    ),
    GetPage(
      name: _Paths.PERSONAL_DETAILS,
      page: () => const PersonalDetailsView(),
      binding: PersonalDetailsBinding(),
    ),
  ];

  // Nested routes for main layout (no transitions)
  static final List<GetPage<dynamic>> nestedRoutes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transitionDuration: const Duration(milliseconds: 0),
    ),
    GetPage(
      name: _Paths.VOD,
      page: () => const VodView(),
      binding: VodBinding(),
      transitionDuration: const Duration(milliseconds: 0),
    ),
    GetPage(
      name: _Paths.ACADEMY,
      page: () => const AcademyView(),
      binding: AcademyBinding(),
      transitionDuration: const Duration(milliseconds: 0),
    ),
    GetPage(
      name: _Paths.FEED,
      page: () => const FeedView(),
      binding: FeedBinding(),
      transitionDuration: const Duration(milliseconds: 0),
    ),
    GetPage(
      name: _Paths.EVENTS,
      page: () => const EventsView(),
      binding: EventsBinding(),
      transitionDuration: const Duration(milliseconds: 0),
    ),
  ];
}
