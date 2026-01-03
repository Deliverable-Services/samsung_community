import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../../main.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class SplashController extends GetxController {
  final count = 0.obs;

  /// Determine initial route based on authentication status
  Future<void> _determineInitialRoute() async {
    // Wait for AuthRepo to be initialized and check auth status
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final authRepo = Get.find<AuthRepo>();
      await authRepo.checkAuthStatus();
      // Determine initial route based on auth status
      if (authRepo.isAuthenticated.value) {
        Get.offAllNamed(Routes.BOTTOM_BAR);
      } else {
        Get.offAllNamed(Routes.ON_BOARDING);
      }
    } catch (e) {
      // If AuthRepo is not found, default to welcome screen
      Get.offAllNamed(Routes.ON_BOARDING);
    }
  }

  @override
  void onInit() {
    super.onInit();
    //_initFirebaseMessaging();
    _determineInitialRoute();
  }

  // Future<void> _initFirebaseMessaging() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   /// 🔹 Permission (iOS + Android 13+)
  //   await messaging.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  //
  //   /// 🔹 Get FCM Token
  //   String? token = await messaging.getToken();
  //   debugPrint('FCM Token: $token');
  //
  //   /// 🔹 Local notification init
  //   const AndroidInitializationSettings androidInit =
  //   AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   const InitializationSettings initSettings =
  //   InitializationSettings(android: androidInit);
  //
  //   await flutterLocalNotificationsPlugin.initialize(initSettings);
  //
  //   /// 🔹 Foreground message
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     _showNotification(message);
  //   });
  //
  //   /// 🔹 App opened from notification
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     debugPrint('Notification clicked');
  //   });
  // }
  //
  // void _showNotification(RemoteMessage message) {
  //   const AndroidNotificationDetails androidDetails =
  //   AndroidNotificationDetails(
  //     'high_importance_channel',
  //     'High Importance Notifications',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //
  //   const NotificationDetails notificationDetails =
  //   NotificationDetails(android: androidDetails);
  //
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     message.notification?.title,
  //     message.notification?.body,
  //     notificationDetails,
  //   );
  // }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
