import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/account_details_form.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/account_detail_controller.dart';

class AccountDetailView extends GetView<AccountDetailController> {
  const AccountDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view event when screen appears
    AnalyticsService.trackScreenView(
      screenName: 'signup screen account details',
      screenClass: 'AccountDetailView',
    );
    // Also log custom event as specified
    AnalyticsService.logEvent(
      eventName: 'signup_account_details_view',
      parameters: {'screen_name': 'signup screen account details'},
    );

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            TitleAppBar(text: "account_details".tr),
            Expanded(
              child: AccountDetailsForm(
                socialMediaController: controller.socialMediaController,
                professionController: controller.professionController,
                bioController: controller.bioController,
                classController: controller.classController,
                selectedCollege: controller.selectedCollege,
                selectedStudent: controller.selectedStudent,
                saveButtonText: 'signUp'.tr,
                isLoading: controller.isSaving.value,
                onSave: (formData) async {
                  // Call the existing submit handler
                  await controller.handleSubmit();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
