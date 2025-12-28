import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/eventer_payment_controller.dart';

class EventerPaymentView extends GetView<EventerPaymentController> {
  const EventerPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Event Registration',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            if (controller.errorMessage.value.isNotEmpty)
              _buildErrorWidget()
            else if (controller.webViewController != null)
              WebViewWidget(controller: controller.webViewController!)
            else
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            if (controller.isLoading.value)
              Container(
                color: AppColors.primary,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading payment page',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Unknown error',
              style: TextStyle(color: AppColors.white, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.reload,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
