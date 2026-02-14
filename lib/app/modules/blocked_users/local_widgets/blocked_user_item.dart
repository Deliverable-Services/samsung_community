import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/models/user_model copy.dart';
import '../controllers/blocked_users_controller.dart';

class BlockedUserItem extends GetView<BlockedUsersController> {
  final UserModel user;

  const BlockedUserItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.overlayContainerBackground,
            ),
            child: ClipOval(
              child:
                  user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? Image.network(
                      user.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.overlayContainerBackground,
                          child: Icon(
                            Icons.person,
                            color: AppColors.textWhiteOpacity70,
                            size: 24.sp,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.overlayContainerBackground,
                      child: Icon(
                        Icons.person,
                        color: AppColors.textWhiteOpacity70,
                        size: 24.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              user.fullName ?? 'username'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.white,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.unblockUser(user.id),
            child: Container(
              width: 124.w,
              height: 38.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(109.68.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(214, 214, 214, 0.2),
                    Color.fromRGBO(112, 112, 112, 0.2),
                  ],
                  stops: [-0.4925, 1.2388],
                ),
                border: Border.all(
                  width: 1.1,
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 8.15.h),
                    blurRadius: 18.21.r,
                    color: const Color(0x1A000000),
                  ),
                  BoxShadow(
                    offset: Offset(0, 33.07.h),
                    blurRadius: 33.07.r,
                    color: const Color(0x17000000),
                  ),
                  BoxShadow(
                    offset: Offset(0, 74.76.h),
                    blurRadius: 45.05.r,
                    color: const Color(0x0D000000),
                  ),
                  BoxShadow(
                    offset: Offset(0, 132.74.h),
                    blurRadius: 53.19.r,
                    color: const Color(0x03000000),
                  ),
                  BoxShadow(
                    offset: Offset(0, 207.5.h),
                    blurRadius: 57.99.r,
                    color: const Color(0x00000000),
                  ),
                  BoxShadow(
                    offset: Offset(2.19.w, -2.19.h),
                    blurRadius: 2.19.r,
                    spreadRadius: -1,
                    color: const Color(0x40000000),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(109.68.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8.625896453857422,
                    sigmaY: 8.625896453857422,
                  ),
                  child: SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImages.blockIcon,
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'unblock'.tr,
                          style: TextStyle(
                            fontFamily: 'Samsung Sharp Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            height: 26.32 / 14,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
