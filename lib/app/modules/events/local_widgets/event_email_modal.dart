import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import 'event_registration_success_modal.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../common/services/supabase_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/event_email_controller.dart';
import 'payment_method_modal.dart';
import '../../../data/models/event_model.dart';
import '../controllers/events_controller.dart';

class EventEmailModal extends StatelessWidget {
  final String? eventId;
  final int? costPoints;
  final VoidCallback? onNext;
  final EventModel? eventModel;

  const EventEmailModal({
    super.key,
    this.eventId,
    this.costPoints,
    this.onNext,
    this.eventModel,
  });

  static void show(
    BuildContext context, {
    String? eventId,
    int? costPoints,
    VoidCallback? onNext,
    EventModel? eventModel,
  }) {
    // Create and put controller
    Get.put(EventEmailController());
    BottomSheetModal.show(
      context,
      content: EventEmailModal(
        eventId: eventId,
        costPoints: costPoints,
        onNext: onNext,
        eventModel: eventModel,
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

  void _handleNext(
    BuildContext context,
    EventEmailController controller,
  ) async {
    if (controller.isValidEmail) {
      final email = controller.email.value;

      final eId = eventModel?.id ?? eventId;
      final cPoints = eventModel?.costPoints ?? costPoints;

      // Navigate to payment method modal if cost is involved
      if (eId != null && eId.isNotEmpty && cPoints != null && cPoints > 0) {
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
          final eventsController = Get.find<EventsController>();

          BottomSheetModal.show(
            Get.context!,
            buttonType: BottomSheetButtonType.none,
            content: Obx(
              () => PaymentMethodModal(
                userPoints: userPoints,
                costPoints: cPoints,
                isLoading: eventsController.isPurchasing.value,
                onPayWithPoints: () async {
                  debugPrint("inside onPayWithPoints");
                  if (eventsController.isPurchasing.value) return;

                  try {
                    // Use passed eventModel if available, otherwise fallback to lookup
                    debugPrint("inside try");
                    EventModel? event = eventModel;

                    if (event == null) {
                      // Find the event object using firstWhereOrNull just in case
                      event = eventsController.allEventsList.firstWhereOrNull(
                        (e) => e.id == eId,
                      );
                      event ??= eventsController.myEventsList.firstWhereOrNull(
                        (e) => e.id == eId,
                      );
                    }

                    if (event != null) {
                      final success = await eventsController
                          .registerEventWithPoints(event);
                      if (success) {
                        // Close PaymentMethodModal using root navigator as it was opened with useRootNavigator: true
                        Navigator.of(Get.context!, rootNavigator: true).pop();
                        
                        if (Get.context != null) {
                           BottomSheetModal.show(
                             Get.context!,
                             content: const EventRegistrationSuccessModal(),
                             buttonType: BottomSheetButtonType.none,
                           );
                        }
                      }
                    } else {
                      debugPrint('Event not found with id: $eId');
                      CommonSnackbar.error('Event not found');
                    }
                  } catch (e) {
                    debugPrint('Error in pay with points: $e');
                    CommonSnackbar.error('Error: $e');
                  }
                 },
                onPayWithCreditCard: eventsController.isPurchasing.value
                    ? () {}
                    : () {
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
            },
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
