import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/personal_details_form.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/personal_details_controller.dart';
import '../local_widgets/profile_picture_widget.dart';

class PersonalDetailsView extends GetView<PersonalDetailsController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view when screen appears
    AnalyticsService.trackScreenView(
      screenName: 'signup screen personal details',
      screenClass: 'PersonalDetailsView',
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            children: [
              TitleAppBar(text: 'personalDetails'.tr),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Center(child: PersonalDetailsProfilePictureWidget()),
                      SizedBox(height: 50.h),
                      PersonalDetailsForm(
                        fullNameController: controller.fullNameController,
                        birthdayController: controller.birthdayController,
                        emailController: controller.emailController,
                        cityController: controller.cityController,
                        selectedGender: controller.selectedGender,
                        selectedDeviceModel: controller.selectedDeviceModel,
                        saveButtonText: 'signUp'.tr,
                        isLoading: false,
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          top: 24.h,
                        ),
                        onSave: (formData) async {
                          // Update controller values from form data
                          controller.fullNameController.text =
                              formData['fullName'] as String? ?? '';
                          controller.emailController.text =
                              formData['email'] as String? ?? '';
                          controller.cityController.text =
                              formData['city'] as String? ?? '';
                          if (formData.containsKey('birthday')) {
                            final birthdayStr = formData['birthday'] as String?;
                            if (birthdayStr != null && birthdayStr.isNotEmpty) {
                              try {
                                controller.selectedBirthday = DateTime.parse(
                                  birthdayStr,
                                );
                              } catch (e) {
                                // Invalid date format, ignore
                              }
                            }
                          }
                          if (formData.containsKey('gender')) {
                            controller.selectedGender.value =
                                formData['gender'] as String?;
                          }

                          // Call the existing handler
                          await controller.handleNext();
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
