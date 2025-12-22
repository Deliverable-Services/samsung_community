import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class UploadFileField extends StatelessWidget {
  final VoidCallback? onTap;
  final String? iconPath;
  final String? uploadedFileName;
  final bool isUploadingMedia;

  const UploadFileField({
    super.key,
    this.onTap,
    this.iconPath,
    this.uploadedFileName,
    this.isUploadingMedia = false,
  });

  @override
  Widget build(BuildContext context) {
    return isUploadingMedia
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.inputGradientStart,
                    AppColors.inputGradientEnd,
                  ],
                  stops: [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.inputShadow,
                    offset: Offset(2.w, -2.h),
                    blurRadius: 2.r,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: EdgeInsets.only(left: 20.w, right: 6.w),
              child: Row(
                children: [
                  Expanded(
                    child: isUploadingMedia
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Uploading...',
                                style: TextStyle(
                                  fontFamily: 'Samsung Sharp Sans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  letterSpacing: 0,
                                  color: AppColors.textWhite,
                                  height: 22 / 14,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            uploadedFileName ?? 'uploadFile'.tr,
                            style: TextStyle(
                              fontFamily: 'Samsung Sharp Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              letterSpacing: 0,
                              color: AppColors.textWhite,
                              height: 22 / 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        iconPath ?? AppImages.uploadFileIcon,
                        width: 30.w,
                        height: 30.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
