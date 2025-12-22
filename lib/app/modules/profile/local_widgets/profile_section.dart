import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/profession_badge.dart';
import '../../../data/helper_widgets/profile_picture_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileSection extends GetView<ProfileController> {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      final isLoading = controller.isLoading.value;
      final isUploadingImage = controller.isUploadingImage.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Center(
              child: ProfilePictureWidget(
                imageUrl: user?.profilePictureUrl,
                isLoading: (isLoading && user == null) || isUploadingImage,
                onTap: controller.selectProfilePicture,
                showAddText: false,
                showAddIcon: false,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              user?.fullName ?? 'user'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 8.h),
            if (user?.bio != null && user!.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14.sp,
                  color: AppColors.textWhiteOpacity70,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 12.h),
            if (user?.profession != null && user!.profession!.isNotEmpty)
              ProfessionBadge(profession: user.profession!),
            SizedBox(height: 24.h),
          ],
        ),
      );
    });
  }
}
