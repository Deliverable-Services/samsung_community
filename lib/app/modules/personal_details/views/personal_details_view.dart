import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/constants/device_model_options.dart';
import '../../../data/constants/gender_options.dart';
import '../../../data/helper_widgets/custom_dropdown.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/personal_details_controller.dart';

class PersonalDetailsView extends GetView<PersonalDetailsController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appBarHeight = TitleAppBar(
      text: 'Personal details',
    ).preferredSize.height;
    final totalOffset = appBarHeight + 20.h;

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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(color: Colors.transparent),
                    Positioned(
                      top: 72.h - totalOffset,
                      left: 116.5.w,
                      child: SizedBox(
                        width: 157.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 105.4310531616211.w,
                              height: 105.4310531616211.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.5, -0.8),
                                  end: const Alignment(0.5, 0.8),
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0),
                                  ],
                                  stops: const [0.0094, 0.8153],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 19.h),
                                    blurRadius: 23.r,
                                    spreadRadius: 0,
                                    color: AppColors.uploadImageShadow,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(2.w),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.uploadImageBackground,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            SizedBox(
                              height: 14.h,
                              child: Center(
                                child: Text(
                                  'addProfilePicture'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                    letterSpacing: 0,
                                    color: AppColors.linkBlue,
                                    height: 1,
                                  ),
                                  textScaler: const TextScaler.linear(1.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 98.h - totalOffset,
                      left: 174.w,
                      child: SvgPicture.asset(
                        AppImages.addIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 231.43.h - totalOffset,
                      left: 20.w,
                      child: SizedBox(
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
                                    return 'fullName'.tr + ' is required';
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'birthday'.tr + ' is required';
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
                                    return 'emailAddress'.tr + ' is required';
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
                                    return 'city'.tr + ' is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),
                              _buildGenderDropdown(),
                              SizedBox(height: 20.h),
                              _buildDeviceModelDropdown(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 807.h - totalOffset,
                      left: 20.w,
                      child: AppButton(
                        onTap: controller.handleNext,
                        text: 'next'.tr,
                        width: 350.w,
                        height: 48.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
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
              controller.genderError.value = '';
            },
          ),
          if (controller.genderError.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                controller.genderError.value,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: Colors.red,
                  height: 18 / 12,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildDeviceModelDropdown() {
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
              controller.deviceModelError.value = '';
            },
          ),
          if (controller.deviceModelError.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                controller.deviceModelError.value,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: Colors.red,
                  height: 18 / 12,
                ),
              ),
            ),
        ],
      );
    });
  }
}
