import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/personal_details_form.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/personal_details_controller.dart';
import '../local_widgets/profile_picture_widget.dart';

class PersonalDetailsView extends GetView<PersonalDetailsController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
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
              TitleAppBar(text: 'Personal details'),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Center(
                        child: PersonalDetailsProfilePictureWidget(),
                      ),
                      SizedBox(height: 20.h),
                      PersonalDetailsForm(
                        fullNameController: controller.fullNameController,
                        birthdayController: controller.birthdayController,
                        emailController: controller.emailController,
                        cityController: controller.cityController,
                        selectedGender: controller.selectedGender,
                        selectedDeviceModel: controller.selectedDeviceModel,
                        saveButtonText: 'next'.tr,
                        isLoading: false,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                              controller.birthdayController.text = birthdayStr;
                              try {
                                controller.selectedBirthday =
                                    DateTime.parse(birthdayStr);
                              } catch (e) {
                                // Invalid date format, ignore
                              }
                            }
                          }
                          if (formData.containsKey('gender')) {
                            controller.selectedGender.value =
                                formData['gender'] as String?;
                          }
                          if (formData.containsKey('deviceModel')) {
                            controller.selectedDeviceModel.value =
                                formData['deviceModel'] as String?;
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
