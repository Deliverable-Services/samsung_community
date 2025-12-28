import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/upload_file_field.dart';
import '../controllers/academy_controller.dart';

class AcademicAudioSubmitModule extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onPublish;
  final VoidCallback? onPublish1;
  final int? pointsToEarn;

  const AcademicAudioSubmitModule({
    super.key,
    required this.title,
    required this.description,
    this.onPublish,
    this.onPublish1,
    this.pointsToEarn,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AcademyController>();

    return Obx(
          () => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Points
          Row(
            children: [
              SvgPicture.asset(
                AppImages.pointsIcon,
                width: 18.w,
                height: 18.h,
              ),
              SizedBox(width: 4.w),
              Text(
                "${pointsToEarn ?? 0}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: AppColors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          /// Title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: AppColors.textWhite,
            ),
          ),

          /// Description
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 14.sp,
              color: AppColors.textWhite,
            ),
          ),

          SizedBox(height: 20.h),

          /// Upload file
          UploadFileField(
            onTap: onPublish1,
            onRemove: () {
              controller.selectedMediaFile.value = null;
              controller.uploadedMediaUrl.value = null;
              controller.uploadedFileName.value = null;
            },
            uploadedFileName: controller.uploadedFileName.value,
            isUploadingMedia: controller.isUploadingMedia.value,
          ),

          SizedBox(height: 24.h),

          /// Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: controller.isConfirmChecked.value,
                onChanged: (value) =>
                controller.isConfirmChecked.value = value ?? false,
                activeColor: AppColors.white,
                checkColor: AppColors.primary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.isConfirmChecked.toggle(),
                  child: Text(
                    'iConfirmGranting'.tr,
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          /// Submit Button (disabled until checked)
          AppButton(
            onTap: onPublish,
            text: 'submitAnswer'.tr,
            width: double.infinity,
            height: 48.h,
          ),
        ],
      ),
    );
  }
}
