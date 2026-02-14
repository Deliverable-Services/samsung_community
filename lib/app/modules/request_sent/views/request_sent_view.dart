import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../controllers/request_sent_controller.dart';

class RequestSentView extends GetView<RequestSentController> {
  const RequestSentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view event when screen appears
    AnalyticsService.trackScreenView(
      screenName: 'signup screen request sent',
      screenClass: 'RequestSentView',
    );
    // Also log custom event as specified
    AnalyticsService.logEvent(
      eventName: 'signup_request_sent_view',
      parameters: {'screen_name': 'signup screen request sent'},
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SvgPicture.asset(
                  AppImages.logo,
                  width: 84.w,
                  height: 78.h,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(height: 30),
                Text(
                  "your_request".tr,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.white,
                    height: 1,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                ),
                Text(
                  "been_sent".tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.linkBlue,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "request_sent_message".tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
