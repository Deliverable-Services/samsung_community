import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import 'event_registration_success_modal.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../routes/app_pages.dart';
import '../controllers/event_email_controller.dart';
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
      if (eId == null || eId.isEmpty) {
        onNext?.call();
        Navigator.of(context, rootNavigator: true).pop();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<EventEmailController>()) {
            Get.delete<EventEmailController>();
          }
        });
        return;
      }

      final eventsController = Get.find<EventsController>();

      EventModel? event = eventModel;
      if (event == null) {
        event = eventsController.allEventsList.firstWhereOrNull(
          (e) => e.id == eId,
        );
        event ??= eventsController.myEventsList.firstWhereOrNull(
          (e) => e.id == eId,
        );
      }

      final EventAccessType accessType =
          event?.accessType ??
          ((costPoints != null && costPoints! > 0)
              ? EventAccessType.internal
              : EventAccessType.external);

      Navigator.of(context, rootNavigator: true).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<EventEmailController>()) {
          Get.delete<EventEmailController>();
        }
      });

      if (accessType == EventAccessType.internal) {
        if (event == null) {
          CommonSnackbar.error('Event not found');
          return;
        }

        final success = await eventsController.registerEventWithPoints(
          event,
          emailForTickets: email,
        );
        if (success && Get.context != null) {
          debugPrint(
            'Analytics: user successfully registered for an internal event',
          );
          // Reload events to refresh the UI (e.g. show cancel button)
          eventsController.loadAllEvents();
          eventsController.loadMyEvents();

          BottomSheetModal.show(
            Get.context!,
            content: const EventRegistrationSuccessModal(),
            buttonType: BottomSheetButtonType.none,
          );
        }
        return;
      }

      Get.toNamed(
        Routes.EVENTER_PAYMENT,
        arguments: {
          'eventId': eId,
          'external_id': event?.externalId,
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
          'emailAddress'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.white,
            fontFamily: 'Samsung Sharp Sans',
          ),
        ),
        SizedBox(height: 8.h),
        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 55.w),
          child: Text(
            'enterYourEmailToReceiveYourTickets'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              height: 22 / 14,
              letterSpacing: 0,
              color: AppColors.textWhiteOpacity60,
              fontFamily: 'Samsung Sharp Sans',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20.h),
        // Email input field
        CustomTextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          placeholder: 'typeEmailAddress'.tr,
          onEditingComplete: () => _handleNext(context, controller),
        ),
        SizedBox(height: 30.h),
        // Next button
        Obx(
          () => AppButton(
            onTap: controller.isValidEmail
                ? () => _handleNext(context, controller)
                : () {},
            text: 'next'.tr,
            width: double.infinity,
            isEnabled: controller.isValidEmail,
          ),
        ),
      ],
    );
  }
}
