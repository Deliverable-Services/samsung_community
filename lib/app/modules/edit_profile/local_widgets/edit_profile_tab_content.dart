import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/helper_widgets/account_details_form.dart';
import '../../../data/helper_widgets/personal_details_form.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileTabContent extends GetView<EditProfileController> {
  const EditProfileTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.selectedTab.value == 0) {
      return PersonalDetailsForm(
        fullNameController: controller.fullNameController,
        birthdayController: controller.birthdayController,
        emailController: controller.emailController,
        cityController: controller.cityController,
        selectedGender: controller.selectedGender,
        selectedDeviceModel: controller.selectedDeviceModel,
        saveButtonText: '',
        isLoading: false,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        hideSaveButton: true,
        onSave: (formData) async {},
        onFieldBlur: (key, value) => controller.saveFieldOnBlur(key, value),
      );
    } else {
      return AccountDetailsForm(
        socialMediaController: controller.socialMediaController,
        professionController: controller.professionController,
        bioController: controller.bioController,
        classController: controller.classController,
        selectedCollege: controller.selectedCollege,
        selectedStudent: controller.selectedStudent,
        saveButtonText: '',
        isLoading: false,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        hideSaveButton: true,
        onSave: (formData) async {},
        onFieldBlur: (key, value) => controller.saveFieldOnBlur(key, value),
      );
    }
  }
}
