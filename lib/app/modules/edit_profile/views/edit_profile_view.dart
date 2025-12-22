import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/account_details_form.dart';
import '../../../data/helper_widgets/personal_details_form.dart';
import '../../../data/helper_widgets/profile_picture_widget.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: [
                      if (controller.selectedTab.value == 0) ...[
                        SizedBox(height: 20.h),
                        _buildProfilePicture(),
                        SizedBox(height: 20.h),
                      ],
                      _buildTabContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(text: 'Personal details', index: 0)),
          Expanded(child: _buildTabButton(text: 'Account details', index: 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String text, required int index}) {
    return Obx(() {
      final isActive = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AppColors.linkBlue
                    : AppColors.textWhiteOpacity70,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: 2.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.linkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProfilePicture() {
    return Obx(() {
      return Column(
        children: [
          ProfilePictureWidget(
            imageFile: controller.selectedImagePath.value,
            imageUrl: controller.profilePictureUrl.value,
            isLoading: controller.isUploadingImage.value,
            onTap: controller.selectProfilePicture,
            showAddText: false,
            showAddIcon: false,
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: controller.selectProfilePicture,
            child: Text(
              'Change profile photo',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.linkBlue,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabContent() {
    if (controller.selectedTab.value == 0) {
      // Personal details tab
      return PersonalDetailsForm(
        fullNameController: controller.fullNameController,
        birthdayController: controller.birthdayController,
        emailController: controller.emailController,
        cityController: controller.cityController,
        selectedGender: controller.selectedGender,
        selectedDeviceModel: controller.selectedDeviceModel,
        saveButtonText: '', // Not used when hideSaveButton is true
        isLoading: false,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        hideSaveButton: true, // Hide save button for auto-save
        onSave: (formData) async {
          // Auto-save is handled by controller listeners
        },
      );
    } else {
      // Account details tab
      return Column(
        children: [
          SizedBox(height: 40.h),
          AccountDetailsForm(
            socialMediaController: controller.socialMediaController,
            professionController: controller.professionController,
            bioController: controller.bioController,
            classController: controller.classController,
            selectedCollege: controller.selectedCollege,
            selectedStudent: controller.selectedStudent,
            saveButtonText: '', // Not used when hideSaveButton is true
            isLoading: false,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            hideSaveButton: true, // Hide save button for auto-save
            onSave: (formData) async {
              // Auto-save is handled by controller listeners
            },
          ),
        ],
      );
    }
  }
}
