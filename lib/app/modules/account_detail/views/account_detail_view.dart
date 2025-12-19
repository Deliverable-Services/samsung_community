import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/college_options.dart';
import '../../../data/helper_widgets/custom_dropdown.dart';
import '../../../data/helper_widgets/custom_radio_button.dart';
import '../../../data/helper_widgets/custom_text.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/account_detail_controller.dart';

class AccountDetailView extends GetView<AccountDetailController> {
  const AccountDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            TitleAppBar(text: "account_details".tr),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.directional(
                  start: 20.w,
                  end: 20.w,
                  top: 68.h,
                ),
                child: Form(
                  key: controller.formKey,
                  child: ValueListenableBuilder(
                    valueListenable: controller.selectedStudent,
                    builder: (value, context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          CustomTextField(
                            label: 'social_media'.tr,
                            controller: controller.socialMediaController,
                            placeholder: 'type'.tr,
                            validator: (value) {
                              if (controller.socialMediaError.isNotEmpty) {
                                return controller.socialMediaError.value;
                              }
                              // Optional field - only validate if value is provided
                              if (value != null && value.trim().isNotEmpty) {
                                if (!controller.isValidUrl(value.trim())) {
                                  return 'Please enter a valid URL';
                                }
                                final platform = controller
                                    .parseSocialMediaPlatform(value.trim());
                                if (platform == null) {
                                  return 'Please enter a valid social media URL (Instagram, Facebook, etc.)';
                                }
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (controller.socialMediaError.isNotEmpty) {
                                controller.socialMediaError.value = '';
                              }
                            },
                          ),
                          SizedBox(height: 30.h),
                          CustomTextField(
                            label: 'profession'.tr,
                            controller: controller.professionController,
                            placeholder: 'type'.tr,
                            validator: (value) {
                              if (controller.professionError.value.isNotEmpty) {
                                return controller.professionError.value;
                              }
                              // Optional field - no validation needed
                              return null;
                            },
                            onChanged: (value) {
                              if (controller.professionError.value.isNotEmpty) {
                                controller.professionError.value = '';
                              }
                            },
                          ),
                          SizedBox(height: 30.h),
                          CustomTextField(
                            label: 'bio'.tr,
                            controller: controller.bioController,
                            placeholder: 'type'.tr,
                            maxLines: 5,
                            validator: (value) {
                              if (controller.bioError.value.isNotEmpty) {
                                return controller.bioError.value;
                              }
                              // Optional field - no validation needed
                              return null;
                            },
                            onChanged: (value) {
                              if (controller.bioError.value.isNotEmpty) {
                                controller.bioError.value = '';
                              }
                            },
                          ),
                          SizedBox(height: 30.h),
                          CustomText("are_you_student".tr),
                          SizedBox(height: 10.h),
                          CustomRadioButton(controller.selectedStudent),
                          if (controller.selectedStudent.value == 'yes')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.h),
                                CustomText("choose_college".tr),
                                SizedBox(height: 10.h),
                                CustomDropDown<String>(
                                  items: CollegeOptions.options.map((college) {
                                    return DropdownMenuItem<String>(
                                      value: college.id,
                                      child: Text(
                                        college.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                          letterSpacing: 0,
                                          color: AppColors.black,
                                          height: 22 / 14,
                                        ),
                                        textScaler: const TextScaler.linear(
                                          1.0,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  valueNotifier: controller.selectedCollege,
                                  hintText: 'select'.tr,
                                  onChanged: (value) {
                                    controller.selectedCollege.value = value;
                                    if (controller
                                        .collegeError
                                        .value
                                        .isNotEmpty) {
                                      controller.collegeError.value = '';
                                    }
                                  },
                                ),
                                if (controller.collegeError.value.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Text(
                                      controller.collegeError.value,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 30.h),
                                CustomTextField(
                                  label: 'name_of_class'.tr,
                                  controller: controller.classController,
                                  placeholder: 'type'.tr,
                                  validator: (value) {
                                    if (controller
                                        .classError
                                        .value
                                        .isNotEmpty) {
                                      return controller.classError.value;
                                    }
                                    if (value == null || value.trim().isEmpty) {
                                      return 'name_of_class'.tr +
                                          ' is required';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (controller
                                        .classError
                                        .value
                                        .isNotEmpty) {
                                      controller.classError.value = '';
                                    }
                                  },
                                ),
                              ],
                            )
                          else
                            // Disable student fields when not a student
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.h),
                                Opacity(
                                  opacity: 0.5,
                                  child: CustomText("choose_college".tr),
                                ),
                                SizedBox(height: 10.h),
                                Opacity(
                                  opacity: 0.5,
                                  child: CustomDropDown<String>(
                                    items: CollegeOptions.options.map((
                                      college,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: college.id,
                                        child: Text(
                                          college.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                            letterSpacing: 0,
                                            color: AppColors.black,
                                            height: 22 / 14,
                                          ),
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    valueNotifier: controller.selectedCollege,
                                    hintText: 'select'.tr,
                                    onChanged: null, // Disabled
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                Opacity(
                                  opacity: 0.5,
                                  child: CustomTextField(
                                    label: 'name_of_class'.tr,
                                    controller: controller.classController,
                                    placeholder: 'type'.tr,
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 30.h),
                          AppButton(
                            onTap: controller.isSaving.value
                                ? null
                                : controller.handleSubmit,
                            text: controller.isSaving.value
                                ? 'saving'.tr
                                : 'signUp'.tr,
                            height: 48.h,
                            isEnabled: !controller.isSaving.value,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
