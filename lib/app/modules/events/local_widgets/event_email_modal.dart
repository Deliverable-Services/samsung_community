import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../controllers/event_email_controller.dart';

class EventEmailModal extends StatelessWidget {
  final VoidCallback? onNext;

  const EventEmailModal({super.key, this.onNext});

  static void show(BuildContext context, {VoidCallback? onNext}) {
    // Create and put controller
    Get.put(EventEmailController());
    BottomSheetModal.show(
      context,
      content: EventEmailModal(onNext: onNext),
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        // Remove controller when modal closes
        Get.delete<EventEmailController>();
      },
    );
  }

  void _handleNext(BuildContext context, EventEmailController controller) {
    if (controller.isValidEmail) {
      onNext?.call();
      Navigator.of(context, rootNavigator: true).pop();
      Get.delete<EventEmailController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventEmailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Email address',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 8.h),
        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 55.w),
          child: Text(
            'Enter your email to receive your tickets.',
            style: TextStyle(
              fontSize: 14.sp,
              height: 22 / 14,
              letterSpacing: 0,
              color: AppColors.textWhiteOpacity60,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20.h),
        // Email input field
        CustomTextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          placeholder: 'Type Email address',
          onEditingComplete: () => _handleNext(context, controller),
        ),
        SizedBox(height: 30.h),
        // Next button
        Obx(
          () => AppButton(
            onTap: controller.isValidEmail
                ? () => _handleNext(context, controller)
                : () {},
            text: 'Next',
            width: double.infinity,
            isEnabled: controller.isValidEmail,
          ),
        ),
      ],
    );
  }
}
