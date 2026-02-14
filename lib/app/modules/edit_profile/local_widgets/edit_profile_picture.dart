import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/profile_picture_widget.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfilePicture extends GetView<EditProfileController> {
  const EditProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
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
              'changeProfilePhoto'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.linkBlue,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),
          ),
        ],
      );
    });
  }
}
