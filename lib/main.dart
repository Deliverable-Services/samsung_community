import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'app/modules/notifications/controllers/notifications_controller.dart';
import 'app/repository/auth_repo/auth_repo.dart';
import 'app/routes/app_pages.dart';

/// ------------------------------------------------------------
/// 🔔 LOCAL NOTIFICATION INSTANCE
/// ------------------------------------------------------------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// ------------------------------------------------------------
/// 🔔 ANDROID NOTIFICATION CHANNEL
/// ------------------------------------------------------------
const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.high,
    );

/// ------------------------------------------------------------
/// 🔔 BACKGROUND MESSAGE HANDLER
/// ------------------------------------------------------------
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Background Message: ${message.notification?.title}');
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar icons to white
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  /// ------------------------------------------------------------
  /// 🔥 FIREBASE INITIALIZATION
  /// ------------------------------------------------------------
  await Firebase.initializeApp();

  if (kDebugMode) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// ------------------------------------------------------------
  /// 🔔 NOTIFICATION PERMISSION (ANDROID 13+ / iOS)
  /// ------------------------------------------------------------
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  /// ------------------------------------------------------------
  /// 🔔 iOS FOREGROUND NOTIFICATION
  /// ------------------------------------------------------------
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  /// ------------------------------------------------------------
  /// 🔔 LOCAL NOTIFICATION INITIALIZATION
  /// ------------------------------------------------------------
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  /// ------------------------------------------------------------
  /// 🔔 CREATE ANDROID CHANNEL
  /// ------------------------------------------------------------
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(notificationChannel);

  /// ------------------------------------------------------------
  /// 🔔 FOREGROUND MESSAGE HANDLER
  /// ------------------------------------------------------------
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannel.id,
            notificationChannel.name,
            channelDescription: notificationChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  });

  /// ------------------------------------------------------------
  /// 🔔 NOTIFICATION TAP HANDLER
  /// ------------------------------------------------------------
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('🔔 Notification Clicked');
    // Example:
    // navigatorKey.currentState?.pushNamed('/notifications');
  });

  /// ------------------------------------------------------------
  /// 🔔 GET FCM TOKEN
  /// ------------------------------------------------------------
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('🔥 FCM TOKEN: $token');

  /// ------------------------------------------------------------
  /// 🌱 ENV & STORAGE
  /// ------------------------------------------------------------
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  await GetPrefs.init();

  /// ------------------------------------------------------------
  /// 🟢 SUPABASE INIT
  /// ------------------------------------------------------------
  await SupabaseService.initialize(
    supabaseUrl: AppConst.supabaseUrl,
    supabaseAnonKey: AppConst.supabaseAnonKey,
  );

  /// ------------------------------------------------------------
  /// 🧠 DEPENDENCY INJECTION
  /// ------------------------------------------------------------
  final languageController = Get.put(LanguageController());
  Get.put(AuthRepo(), permanent: true);
  Get.put(ProfileService(), permanent: true);

  final lifecycleService = Get.put(AppLifecycleService(), permanent: true);
  await lifecycleService.initialize();

  /// ------------------------------------------------------------
  /// 🚀 RUN APP
  /// ------------------------------------------------------------
  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 905),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Application',
          initialBinding: AppBinding(),
          navigatorKey: navigatorKey,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          translations: LocalString(),
          locale: Locale(languageController.currentLocale),
          theme: ThemeData(fontFamily: 'Samsung Sharp Sans'),
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Brightness.light, // White icons for Android
                statusBarBrightness:
                    Brightness.dark, // Dark content for iOS (shows light icons)
              ),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              ),
            );
          },
        );
      },
    ),
  );
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NotificationsController>(
      NotificationsController(),
      permanent: true,
    );
  }
}
