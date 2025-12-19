import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../controllers/personal_details_controller.dart';

class ProfilePictureWidget extends GetView<PersonalDetailsController> {
  final double topOffset;
  final double totalOffset;

  const ProfilePictureWidget({
    super.key,
    required this.topOffset,
    required this.totalOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset - totalOffset,
      left: 116.5.w,
      child: SizedBox(
        width: 157.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: controller.selectProfilePicture,
              child: Obx(() {
                final imageFile = controller.selectedImagePath.value;
                final imageUrl = controller.profilePictureUrl.value;
                final isLoading = controller.isUploadingImage.value;

                return Container(
                  width: 105.4310531616211.w,
                  height: 105.4310531616211.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: const Alignment(-0.5, -0.8),
                      end: const Alignment(0.5, 0.8),
                      colors: [Colors.white, Colors.white.withOpacity(0)],
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.uploadImageBackground,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: imageFile != null
                              ? Image.file(imageFile, fit: BoxFit.cover)
                              : imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.uploadImageBackground,
                                    );
                                  },
                                )
                              : null,
                        ),
                      ),
                      if (isLoading)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
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
    );
  }
}

class AddIconWidget extends GetView<PersonalDetailsController> {
  final double topOffset;
  final double totalOffset;

  const AddIconWidget({
    super.key,
    required this.topOffset,
    required this.totalOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset - totalOffset,
      left: 174.w,
      child: GestureDetector(
        onTap: controller.selectProfilePicture,
        child: SvgPicture.asset(AppImages.addIcon, fit: BoxFit.contain),
      ),
    );
  }
}
