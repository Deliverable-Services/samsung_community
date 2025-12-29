import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/services/analytics_service.dart';
import '../constants/app_button.dart';
import '../constants/app_images.dart';

class DeviceNotSupportedOverlay extends StatelessWidget {
  const DeviceNotSupportedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view event when modal appears
    AnalyticsService.trackScreenView(
      screenName: 'Popup device not approved',
      screenClass: 'DeviceNotSupportedOverlay',
    );
    // Also log custom event as specified
    AnalyticsService.logEvent(
      eventName: 'Popup_device_not_approved_click',
      parameters: {'screen_name': 'Popup device not approved'},
    );

    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Central warning icon
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(259.43.r),
                          bottomRight: Radius.circular(259.43.r),
                          bottomLeft: Radius.circular(259.43.r),
                        ),
                        child: Image.asset(
                          AppImages.notSupportedIcon,
                          width: 50.w,
                          height: 50.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: -15.w,
                        child: Image.asset(
                          AppImages.star3Icon,
                          width: 14.w,
                          height: 14.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8.h,
                        left: -25.w,
                        child: Image.asset(
                          AppImages.star3Icon,
                          width: 9.w,
                          height: 9.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0.h,
                        right: -22.w,
                        child: Image.asset(
                          AppImages.star3Icon,
                          width: 18.w,
                          height: 18.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 17.h,
                        right: -25.w,
                        child: Image.asset(
                          AppImages.star3Icon,
                          width: 7.w,
                          height: 7.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 270.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'deviceNotSupported'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700, // Bold
                          fontSize: 18.sp, // font-size: 18px
                          height: 24 / 18, // line-height: 24px
                          letterSpacing: 0, // letter-spacing: 0px
                          color: const Color.fromRGBO(
                            255,
                            255,
                            255,
                            1,
                          ), // background: #FFFFFF
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'needSamsungDevice'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          height: 22 / 14,
                          letterSpacing: 0,
                          color: const Color(0xFFBDBDBD), // background: #BDBDBD
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          AppButton(
            onTap: () {
              // Log button click event
              AnalyticsService.logButtonClick(
                screenName: 'Popup device not approved',
                buttonName: 'Go to store',
                eventName: 'Popup_device_not_approved_click',
              );
              // TODO: Handle go to store action
            },
            text: 'goToStore'.tr,
            width: 350.w,
            height: 48.h,
          ),
        ],
      ),
    );
  }
}
