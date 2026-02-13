import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/models/user_model copy.dart';
import '../../../routes/app_pages.dart';
import '../controllers/followers_following_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/option_item.dart';

class FollowerFollowingItem extends GetView<FollowersFollowingController> {
  final UserModel user;
  final bool isFollowersTab;

  const FollowerFollowingItem({
    super.key,
    required this.user,
    required this.isFollowersTab,
  });

  @override
  String? get tag => Get.parameters['userId'] ?? 'current_user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
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
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToProfile,
              child: Text(
                user.fullName ?? 'username',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.white,
                  fontFamily: 'Samsung Sharp Sans',
                ),
              ),
            ),
          ),
          if (!_isCurrentUser(user.id)) ...[
            SizedBox(width: 12.w),
            Obx(() {
              final isFollowing = controller.isFollowing(user.id);
              final isFollowedBy = controller.isFollowedBy(user.id);
              final showFollowBack = isFollowedBy && !isFollowing;

              return Row(
                children: [
                  if (showFollowBack)
                    _buildFollowBackButton()
                  else
                    _buildMessageButton(),
                  if (isFollowing) ...[
                    SizedBox(width: 8.w),
                    _buildMoreButton(user.id),
                  ],
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowBackButton() {
    return GestureDetector(
      onTap: () => controller.followUser(user.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF20AEFE), Color(0xFF135FFF)],
            stops: [0.0041, 1.0042],
          ),
        ),
        child: Text(
          'followBack'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
            fontFamily: 'Samsung Sharp Sans',
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton() {
    return GestureDetector(
      onTap: () => controller.navigateToChat(user.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: AppColors.overlayContainerBackground,
        ),
        child: Text(
          'message'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
            fontFamily: 'Samsung Sharp Sans',
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(String userId) {
    return GestureDetector(
      onTap: () => _showMoreOptions(userId),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors
              .overlayContainerBackground, // Fixed: removed invalid color
        ),
        child: Icon(Icons.more_vert, color: AppColors.white, size: 20.sp),
      ),
    );
  }

  bool _isCurrentUser(String userId) {
    final currentUser = SupabaseService.currentUser;
    return currentUser != null && currentUser.id == userId;
  }

  void _navigateToProfile() {
    if (_isCurrentUser(user.id)) {
      Get.toNamed(Routes.PROFILE);
    } else {
      Get.toNamed(Routes.USER_PROFILE, parameters: {'userId': user.id});
    }
  }

  void _showMoreOptions(String userId) {
    final context = Get.context;
    if (context == null) return;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionItem(
            text: 'block'.tr,
            boxTextWidget: SvgPicture.asset(
              AppImages.blockIcon,
              width: 14.w,
              height: 14.h,
              fit: BoxFit.contain,
            ),
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              controller.blockUser(userId);
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
