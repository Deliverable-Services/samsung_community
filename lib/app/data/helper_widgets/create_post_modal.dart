import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import 'custom_text_field.dart';
import 'upload_file_field.dart';

class CreatePostModal extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback? onPublish;
  final VoidCallback? onPublish1;
  final File? selectedMediaFile;
  final String? uploadedMediaUrl;
  final String? uploadedFileName;
  final bool isUploadingMedia;

  const CreatePostModal({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.onPublish,
    this.onPublish1,
    this.selectedMediaFile,
    this.uploadedMediaUrl,
    this.uploadedFileName,
    this.isUploadingMedia = false,
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
            onPublish1?.call();
          },
          uploadedFileName: uploadedFileName,
          isUploadingMedia: isUploadingMedia,
        ),
        if (selectedMediaFile != null || uploadedMediaUrl != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _MediaPreview(
                mediaFile: selectedMediaFile,
                mediaUrl: uploadedMediaUrl,
                fileName: uploadedFileName,
                isUploading: isUploadingMedia,
              ),
            ],
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

class _MediaPreview extends StatelessWidget {
  final File? mediaFile;
  final String? mediaUrl;
  final String? fileName;
  final bool isUploading;

  const _MediaPreview({
    this.mediaFile,
    this.mediaUrl,
    this.fileName,
    this.isUploading = false,
  });

  bool get _isVideo {
    if (mediaFile != null) {
      final path = mediaFile!.path.toLowerCase();
      return path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi');
    }
    if (mediaUrl != null) {
      return mediaUrl!.toLowerCase().contains('.mp4') ||
          mediaUrl!.toLowerCase().contains('.mov') ||
          mediaUrl!.toLowerCase().contains('.avi');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.overlayContainerBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUploading)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(width: 12.w),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                color: AppColors.backgroundDark,
              ),
              child: _isVideo
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        if (mediaFile != null)
                          Image.file(
                            mediaFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        else if (mediaUrl != null)
                          CachedNetworkImage(
                            imageUrl: mediaUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorWidget: (_, __, ___) => Icon(
                              Icons.videocam,
                              size: 48.sp,
                              color: AppColors.textWhiteOpacity60,
                            ),
                          ),
                        Icon(
                          Icons.play_circle_filled,
                          size: 48.sp,
                          color: AppColors.textWhite,
                        ),
                      ],
                    )
                  : mediaFile != null
                  ? Image.file(
                      mediaFile!,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : mediaUrl != null
                  ? CachedNetworkImage(
                      imageUrl: mediaUrl!,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.image,
                        size: 48.sp,
                        color: AppColors.textWhiteOpacity60,
                      ),
                    )
                  : const SizedBox(),
            ),
            if (fileName != null)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Icon(
                      _isVideo ? Icons.videocam : Icons.image,
                      size: 16.sp,
                      color: AppColors.textWhiteOpacity60,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        fileName!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textWhiteOpacity70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
