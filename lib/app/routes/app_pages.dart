import 'package:get/get.dart';

import '../data/middleware/auth_guard.dart';
import '../data/middleware/guest_guard.dart';
import '../modules/academy/bindings/academy_binding.dart';
import '../modules/academy/views/academy_view.dart';
import '../modules/account_detail/bindings/account_detail_binding.dart';
import '../modules/account_detail/views/account_detail_view.dart';
import '../modules/blocked_users/bindings/blocked_users_binding.dart';
import '../modules/blocked_users/views/blocked_users_view.dart';
import '../modules/bottom_bar/bindings/bottom_bar_binding.dart';
import '../modules/bottom_bar/views/bottom_bar_view.dart';
import '../modules/chat_screen/bindings/chat_screen_binding.dart';
import '../modules/chat_screen/views/chat_screen_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/events/bindings/events_binding.dart';
import '../modules/events/views/events_view.dart';
import '../modules/feed/bindings/feed_binding.dart';
import '../modules/feed/views/feed_view.dart';
import '../modules/followers_following/bindings/followers_following_binding.dart';
import '../modules/followers_following/views/followers_following_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/messages/bindings/messages_binding.dart';
import '../modules/messages/views/messages_view.dart';
import '../modules/on_boarding/bindings/on_boarding_binding.dart';
import '../modules/on_boarding/views/on_boarding_view.dart';
import '../modules/personal_details/bindings/personal_details_binding.dart';
import '../modules/personal_details/views/personal_details_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/request_sent/bindings/request_sent_binding.dart';
import '../modules/request_sent/views/request_sent_view.dart';
import '../modules/sign_up/bindings/sign_up_binding.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';
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
    // Protected routes - require authentication
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.BOTTOM_BAR,
      page: () => const BottomBarView(),
      binding: BottomBarBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.VOD,
      page: () => const VodView(),
      binding: VodBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.ACADEMY,
      page: () => const AcademyView(),
      binding: AcademyBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.FEED,
      page: () => const FeedView(),
      binding: FeedBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.EVENTS,
      page: () => const EventsView(),
      binding: EventsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.PERSONAL_DETAILS,
      page: () => const PersonalDetailsView(),
      binding: PersonalDetailsBinding(),
      // No AuthGuard - accessible during signup flow
    ),
    GetPage(
      name: _Paths.ACCOUNT_DETAIL,
      page: () => const AccountDetailView(),
      binding: AccountDetailBinding(),
    ),
    GetPage(
      name: _Paths.REQUEST_SENT,
      page: () => const RequestSentView(),
      binding: RequestSentBinding(),
    ),
    // Public routes - no authentication required
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    // Auth routes - only accessible when NOT authenticated
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: _Paths.ON_BOARDING,
      page: () => const OnBoardingView(),
      binding: OnBoardingBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: _Paths.VERIFICATION_CODE,
      page: () => const VerificationCodeView(),
      binding: VerificationCodeBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: _Paths.VERIFICATION_CODE_BY_LOGIN,
      page: () => const VerificationCodeByLoginView(),
      binding: VerificationCodeByLoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.BLOCKED_USERS,
      page: () => const BlockedUsersView(),
      binding: BlockedUsersBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.FOLLOWERS_FOLLOWING,
      page: () => const FollowersFollowingView(),
      binding: FollowersFollowingBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGES,
      page: () => const MessagesView(),
      binding: MessagesBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: _Paths.CHAT_SCREEN,
      page: () => const ChatScreenView(),
      binding: ChatScreenBinding(),
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
