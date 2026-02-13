import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/device_model_options.dart';
import '../../../data/constants/gender_options.dart';
import '../../../data/helper_widgets/custom_dropdown.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../controllers/personal_details_controller.dart';

class PersonalDetailsForm extends GetView<PersonalDetailsController> {
  const PersonalDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'fullName'.tr,
              controller: controller.fullNameController,
              keyboardType: TextInputType.name,
              placeholder: 'type'.tr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'fullName'.tr + ' is_required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.selectDate();
              },
              child: AbsorbPointer(
                child: CustomTextField(
                  label: 'birthday'.tr,
                  controller: controller.birthdayController,
                  keyboardType: TextInputType.datetime,
                  placeholder: 'type'.tr,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'birthday'.tr + ' is_required'.tr;
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              label: 'emailAddress'.tr,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              placeholder: 'type'.tr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'emailAddress'.tr + ' is_required'.tr;
                }
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              label: 'city'.tr,
              controller: controller.cityController,
              keyboardType: TextInputType.text,
              placeholder: 'type'.tr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'city'.tr + ' is_required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            _GenderDropdown(controller: controller),
            SizedBox(height: 20.h),
            _DeviceModelDropdown(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final PersonalDetailsController controller;

  const _GenderDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.count.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 14.h,
            child: Text(
              'gender'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                letterSpacing: 0,
                color: AppColors.white,
                height: 22 / 22,
              ),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
          SizedBox(height: 10.h),
          CustomDropDown<String>(
            items: GenderOptions.options.map((option) {
              return DropdownMenuItem<String>(
                value: option.id,
                child: Text(
                  option.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    letterSpacing: 0,
                    color: AppColors.black,
                    height: 22 / 14,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
              );
            }).toList(),
            valueNotifier: controller.selectedGender,
            hintText: 'select'.tr,
            onChanged: (String? value) {
              controller.selectedGender.value = value;
            },
          ),
        ],
      );
    });
  }
}

class _DeviceModelDropdown extends StatelessWidget {
  final PersonalDetailsController controller;

  const _DeviceModelDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.count.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 14.h,
            child: Text(
              'deviceModel'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                letterSpacing: 0,
                color: AppColors.white,
                height: 22 / 22,
              ),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
          SizedBox(height: 10.h),
          CustomDropDown<String>(
            items: DeviceModelOptions.options.map((option) {
              return DropdownMenuItem<String>(
                value: option.id,
                child: Text(
                  option.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    letterSpacing: 0,
                    color: AppColors.black,
                    height: 22 / 14,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
              );
            }).toList(),
            valueNotifier: controller.selectedDeviceModel,
            hintText: 'select'.tr,
            onChanged: (String? value) {
              controller.selectedDeviceModel.value = value;
            },
          ),
        ],
      );
    });
  }
}
