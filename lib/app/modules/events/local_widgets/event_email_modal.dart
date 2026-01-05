import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../common/services/supabase_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/event_email_controller.dart';
import 'payment_method_modal.dart';

class EventEmailModal extends StatelessWidget {
  final String? eventId;
  final int? costPoints;
  final VoidCallback? onNext;

  const EventEmailModal({
    super.key,
    this.eventId,
    this.costPoints,
    this.onNext,
  });

  static void show(
    BuildContext context, {
    String? eventId,
    int? costPoints,
    VoidCallback? onNext,
  }) {
    // Create and put controller
    Get.put(EventEmailController());
    BottomSheetModal.show(
      context,
      content: EventEmailModal(
        eventId: eventId,
        costPoints: costPoints,
        onNext: onNext,
      ),
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        // Remove controller when modal closes with a small delay
        // to ensure widget tree is done with it
        Future.microtask(() {
          if (Get.isRegistered<EventEmailController>()) {
            Get.delete<EventEmailController>();
          }
        });
      },
    );
  }

  void _handleNext(BuildContext context, EventEmailController controller) async {
    if (controller.isValidEmail) {
      final email = controller.email.value;

      // Navigate to payment method modal if cost is involved
      if (eventId != null && eventId!.isNotEmpty && costPoints != null && costPoints! > 0) {
        // Close modal first
        Navigator.of(context, rootNavigator: true).pop();

        // Delete controller after frame is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<EventEmailController>()) {
             // Don't delete immediately if we need email later, but for now we pass it or new flow starts.
             // Actually, we are starting a NEW modal, so this controller is done.
            Get.delete<EventEmailController>();
          }
        });

        // Fetch user points (Mocking or fetching here before showing next modal)
        // Ideally this should be in a controller, but for UI flow transition:
        int userPoints = 0;
        try {
           final userId = SupabaseService.currentUser?.id;
           if (userId != null) {
              final response = await SupabaseService.client
                  .from('users')
                  .select('points_balance')
                  .eq('id', userId)
                  .single();
              userPoints = response['points_balance'] as int? ?? 0;
           }
        } catch (e) {
           debugPrint('Error fetching points: $e');
        }

        if (Get.context != null) {
           BottomSheetModal.show(
              Get.context!,
              buttonType: BottomSheetButtonType.none, // Custom close button in modal content
              content: PaymentMethodModal(
                 userPoints: userPoints,
                 costPoints: costPoints!,
                 onPayWithPoints: () {
                    // TODO: Implement pay with points logic
                    debugPrint('Pay with points clicked');
                 },
                 onPayWithCreditCard: () {
                    Get.back(); // Close payment method modal
                    // Navigate to payment screen
                    Get.toNamed(
                      Routes.EVENTER_PAYMENT,
                      arguments: {
                        'eventId': eventId,
                        'email': email,
                        'config': {
                          'lang': 'en_EN',
                          'colorScheme': '#FFFFFF',
                          'colorScheme2': '#000000',
                          'colorSchemeButton': '#1FA3FF',
                          'showBanner': false,
                          'showEventDetails': false,
                          'showBackground': true,
                          'showLocationDescription': false,
                          'showSeller': false,
                          'showPoweredBy': false,
                        },
                      },
                    );
                 },
              ),
           );
        }

      } else if (eventId != null && eventId!.isNotEmpty) {
        // Free event or no cost info? Just go to register directly (Eventer)
        // Close modal first
        Navigator.of(context, rootNavigator: true).pop();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<EventEmailController>()) {
            Get.delete<EventEmailController>();
          }
        });

         Get.toNamed(
          Routes.EVENTER_PAYMENT,
          arguments: {
            'eventId': eventId,
            'email': email,
            'config': {
                // defaults
               'lang': 'en_EN',
            }
          },
        );

      } else {
        // Fallback to onNext callback if no eventId
        onNext?.call();
        Navigator.of(context, rootNavigator: true).pop();

        // Delete controller after frame is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<EventEmailController>()) {
            Get.delete<EventEmailController>();
          }
        });
      }
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
