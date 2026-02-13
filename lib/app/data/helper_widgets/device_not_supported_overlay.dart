import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/services/analytics_service.dart';
import '../constants/app_button.dart';
import '../constants/app_images.dart';

class DeviceNotSupportedOverlay extends StatefulWidget {
  const DeviceNotSupportedOverlay({super.key});

  @override
  State<DeviceNotSupportedOverlay> createState() =>
      _DeviceNotSupportedOverlayState();
}

class _DeviceNotSupportedOverlayState extends State<DeviceNotSupportedOverlay> {
  bool _hasLoggedAnalytics = false;

  Future<void> _openPlayStore() async {
    try {
      // Play Store search URL format
      const searchQuery = 'S Society';
      final encodedQuery = Uri.encodeComponent(searchQuery);
      final playStoreUrl = Uri.parse(
        'https://play.google.com/store/search?q=$encodedQuery&c=apps',
      );

      // Try to open with Play Store app first (market:// scheme)
      final marketUrl = Uri.parse('market://search?q=$encodedQuery');

      if (await canLaunchUrl(marketUrl)) {
        await launchUrl(marketUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(playStoreUrl)) {
        // Fallback to web Play Store
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch Play Store URL');
      }
    } catch (e) {
      debugPrint('Error opening Play Store: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Log analytics once when modal first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoggedAnalytics) {
        _hasLoggedAnalytics = true;
        // Log screen view event when modal appears
        AnalyticsService.logScreenView(
          screenName: 'Popup device not approved',
          screenClass: 'DeviceNotSupportedOverlay',
        );
        // Also log custom event as specified
        AnalyticsService.logEvent(
          eventName: 'Popup_device_not_approved_click',
          parameters: {'screen_name': 'Popup device not approved'},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          fontFamily: 'Samsung Sharp Sans',
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
                          fontFamily: 'Samsung Sharp Sans',
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
            onTap: () async {
              // Log button click event
              AnalyticsService.logButtonClick(
                screenName: 'Popup device not approved',
                buttonName: 'Go to store',
                eventName: 'Popup_device_not_approved_click',
              );
              // Open Play Store and search for "S Society"
              await _openPlayStore();
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
