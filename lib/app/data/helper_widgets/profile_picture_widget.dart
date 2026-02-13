import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class ProfilePictureWidget extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool showAddText;
  final bool showAddIcon;
  final dynamic width;

  const ProfilePictureWidget({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.isLoading = false,
    this.onTap,
    this.showAddText = true,
    this.showAddIcon = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 157.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: width ?? 105.4310531616211.w,
              height: width ?? 105.4310531616211.h,
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
                          ? Image.file(imageFile!, fit: BoxFit.cover)
                          : imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.uploadImageBackground,
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              color: AppColors.textWhiteOpacity70,
                              size: 24.sp,
                            ),
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
                  if (!isLoading &&
                      showAddIcon &&
                      imageFile == null &&
                      (imageUrl == null || imageUrl!.isEmpty))
                    Center(
                      child: GestureDetector(
                        onTap: onTap,
                        child: SvgPicture.asset(
                          AppImages.addIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showAddText) ...[
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
        ],
      ),
    );
  }
}
