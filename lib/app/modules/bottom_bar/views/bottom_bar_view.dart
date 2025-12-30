import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../../../data/helper_widgets/device_not_supported_overlay.dart';
import '../../../data/helper_widgets/navbar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/bottom_bar_controller.dart';

class BottomBarView extends GetView<BottomBarController> {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<BottomBarController>()) {
    } else {
      // If checking is still in progress after a delay, force completion
      if (controller.isCheckingDevice.value) {
        Future.delayed(const Duration(seconds: 6), () {
          if (controller.isCheckingDevice.value) {
            controller.isCheckingDevice.value = false;
            controller.isSamsungDevice.value = false;
          }
        });
      }
    }
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Obx(() {
          final shouldShowOverlay = false;
          // final shouldShowOverlay =
          //     !controller.isSamsungDevice.value &&
          //     !controller.isCheckingDevice.value;

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 16.h,
                    ),
                    child: BottomNavBar(),
                  ),
                ],
              ),
              if (shouldShowOverlay)
                Positioned.fill(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Overlay background - can be used to dismiss if needed
                        },
                        child: Container(color: AppColors.overlayBackground),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: AppColors.overlayContainerBackground,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.r),
                              topRight: Radius.circular(30.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, -6.h),
                                blurRadius: 50.r,
                                spreadRadius: 0,
                                color: AppColors.overlayContainerShadow,
                              ),
                            ],
                          ),
                          child: const DeviceNotSupportedOverlay(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
