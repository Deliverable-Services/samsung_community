import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/common/services/app_lifecycle_service.dart';
import 'app/common/services/profile_service.dart';
import 'app/common/services/supabase_service.dart';
import 'app/data/constants/app_consts.dart';
import 'app/data/localization/get_prefs.dart';
import 'app/data/localization/language_controller.dart';
import 'app/data/localization/local_string.dart';
import 'app/repository/auth_repo/auth_repo.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// /// 🔹 Background handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('Background Message: ${message.notification?.title}');
// }

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');

    // Enable Analytics debug mode in debug builds
    if (kDebugMode) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      debugPrint('Firebase Analytics debug mode enabled');
    }
  } catch (e) {
    debugPrint('Warning: Failed to initialize Firebase: $e');
  }

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Failed to load ..env file: $e');
  }
  await GetStorage.init();
  await GetPrefs.init();
  final supabaseUrl = AppConst.supabaseUrl;
  final supabaseAnonKey = AppConst.supabaseAnonKey;
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint(
      'Error: Supabase credentials are missing. Please check your ..env file.',
    );
  }
  await SupabaseService.initialize(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  LanguageController _languageController = Get.put(LanguageController());
  Get.put(AuthRepo(), permanent: true);
  Get.put(ProfileService(), permanent: true);
  final appLifecycleService = Get.put(AppLifecycleService(), permanent: true);
  await appLifecycleService.initialize();
  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 905),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: "Application",
          navigatorKey: navigatorKey,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          theme: ThemeData(fontFamily: 'Samsung Sharp Sans'),
          translations: LocalString(),
          locale: Locale(_languageController.currentLocale),
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    ),
  );
}
