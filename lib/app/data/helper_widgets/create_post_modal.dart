import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import 'custom_text_field.dart';
import 'upload_file_field.dart';

class CreatePostModal extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback? onPublish;

  const CreatePostModal({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'publishingAPost'.tr,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        // Description
        Text(
          'publishingAPostDescription'.tr,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontSize: 14.sp,
            height: 22 / 14,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 20.h),
        // Title Input Field
        CustomTextField(
          controller: titleController,
          label: 'title'.tr,
          placeholder: 'typeATitle'.tr,
          maxLines: 1,
          width: double.infinity,
        ),
        SizedBox(height: 25.h),
        // Description Text Area Field
        CustomTextField(
          controller: descriptionController,
          label: 'description'.tr,
          placeholder: 'typeADescription'.tr,
          maxLines: 5,
          width: double.infinity,
        ),
        SizedBox(height: 25.h),
        // Upload File Field
        UploadFileField(
          onTap: () {
            // TODO: Implement file upload functionality
            print('Upload file tapped');
          },
        ),
        SizedBox(height: 32.h),
        // Publish Button
        Center(
          child: AppButton(
            onTap: () {
              // TODO: Implement publish functionality
              onPublish?.call();
            },
            text: 'publish'.tr,
            width: double.infinity,
            height: 48.h,
          ),
        ),
      ],
    );
  }
}
