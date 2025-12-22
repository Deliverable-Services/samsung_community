import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../../../data/helper_widgets/navbar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/bottom_bar_controller.dart';

class BottomBarView extends GetView<BottomBarController> {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Obx(
                () => Navbar(totalPoints: controller.totalPoints.value),
              ),
            ),
            Expanded(
              child: Navigator(
                key: Get.nestedKey(1),
                initialRoute: Routes.HOME,
                onGenerateRoute: (settings) {
                  final nestedRoute = AppPages.nestedRoutes.firstWhere(
                    (route) => route.name == settings.name,
                    orElse: () => AppPages.nestedRoutes.first,
                  );

                  return GetPageRoute(
                    page: nestedRoute.page,
                    binding: nestedRoute.binding,
                    middlewares: nestedRoute.middlewares,
                    settings: settings,
                    transition: nestedRoute.transition,
                    transitionDuration:
                        nestedRoute.transitionDuration ??
                        const Duration(milliseconds: 300),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 16.h),
              child: BottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }
}
