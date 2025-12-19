import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../repository/auth_repo/auth_repo.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authRepo = Get.find<AuthRepo>();

      if (!authRepo.isAuthenticated.value) {
        return const RouteSettings(name: Routes.LOGIN);
      }

      return null;
    } catch (e) {
      debugPrint('AuthGuard: AuthRepo not found, redirecting to login');
      return const RouteSettings(name: Routes.LOGIN);
    }
  }
}
