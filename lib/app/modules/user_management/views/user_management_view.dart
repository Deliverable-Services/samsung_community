import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../controllers/user_management_controller.dart';
import '../../../data/models/user_model.dart';

import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';

class UserManagementView extends GetView<UserManagementController> {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            const SizedBox.shrink(), // Hiding default back button to center title if needed or standard
        title: Text(
          'userApproval'.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textWhite,
            fontFamily: 'Samsung Sharp Sans', // Assuming font family
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: CircleAvatar(
              radius: 15.r,
              backgroundColor: AppColors.buttonGrey.withOpacity(0.3),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pendingUsers.isEmpty) {
          return Center(
            child: Text(
              'noPendingUsersFound'.tr,
              style: TextStyle(
                color: AppColors.textWhiteSecondary,
                fontSize: 16.sp,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          itemCount: controller.pendingUsers.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final user = controller.pendingUsers[index];
            return _buildUserItem(context, user);
          },
        );
      }),
    );
  }

  Widget _buildUserItem(BuildContext context, UserModel user) {
    return Row(
      children: [
        // Profile Picture & Name wrapped in GestureDetector
        Expanded(
          child: GestureDetector(
            onTap: () => _showUserDetails(context, user),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child:
                      user.profilePictureUrl != null &&
                          user.profilePictureUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.profilePictureUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.grey),
                          errorWidget: (context, url, error) =>
                              Image.asset(AppImages.avatar, fit: BoxFit.cover),
                        )
                      : Image.asset(AppImages.avatar, fit: BoxFit.cover),
                ),
                SizedBox(width: 12.w),

                // Username
                Expanded(
                  child: Text(
                    user.fullName ??
                        user.phoneNumber, // Fallback to phone if name empty
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Samsung Sharp Sans',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Action Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              svgPath: AppImages.approveUser,
              onTap: () => controller.approveUser(user),
            ),
            SizedBox(width: 12.w),
            _buildActionButton(
              svgPath: AppImages.rejectUser,
              onTap: () => controller.rejectUser(user),
            ),
          ],
        ),
      ],
    );
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.back,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Pic in Modal
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child:
                  user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.profilePictureUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.grey),
                      errorWidget: (context, url, error) =>
                          Image.asset(AppImages.avatar, fit: BoxFit.cover),
                    )
                  : Image.asset(AppImages.avatar, fit: BoxFit.cover),
            ),
            SizedBox(height: 16.h),

            // Name
            Text(
              user.fullName ?? user.phoneNumber,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),
            SizedBox(height: 20.h),

            // Date of Birth
            CustomTextField(
              label: 'dateOfBirth'.tr,
              controller: TextEditingController(
                text:
                    user.birthday?.toIso8601String().split('T')[0] ??
                    'notAvailable'.tr,
              ),
              readOnly: true,
            ),
            SizedBox(height: 16.h),

            // Gender
            CustomTextField(
              label: 'gender'.tr,
              controller: TextEditingController(
                text: user.gender?.name.tr ?? 'notAvailable'.tr,
              ),
              readOnly: true,
            ),
            SizedBox(height: 16.h),

            // City
            CustomTextField(
              label: 'city'.tr,
              controller: TextEditingController(
                text: user.city ?? 'notAvailable'.tr,
              ),
              readOnly: true,
            ),
            SizedBox(height: 16.h),

            // Social Media
            CustomTextField(
              label: 'social_media'.tr,
              // Displaying raw JSON or processing it? Assuming it's a map, showing first link or just text if stored as string?
              // The model says Map<String, dynamic> socialMediaLinks.
              // I'll join keys and values or just showing something meaningful.
              // Screenshot shows URL. I'll iterate or show a specific one if known, or just dummy for now if structure is complex.
              controller: TextEditingController(
                text: user.socialMediaLinks.values.isNotEmpty
                    ? user.socialMediaLinks.values.first.toString()
                    : 'notAvailable'.tr,
              ),
              readOnly: true,
            ),
            SizedBox(height: 40.h),

            // Modal Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildModalActionButton(
                    text: 'rejection'.tr,
                    icon: Icons.close,
                    iconColor: const Color(0xFFFF453A),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      controller.rejectUser(user);
                    },
                    isReject: true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildModalActionButton(
                    text: 'approval'.tr,
                    icon: Icons.check,
                    iconColor: AppColors
                        .white, // Actually check icon is usually black on white bg, but design shows white icon?
                    // Screenshot check icon: White circle with black check? Or just white check?
                    // Screenshot shows: Rejection has red circle with X. Approval has white circle with Check.
                    // The text is white.
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      controller.approveUser(user);
                    },
                    isReject: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildModalActionButton({
    required String text,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isReject,
  }) {
    // Gradient for the border source
    final borderGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color.fromRGBO(242, 242, 242, 0.2),
        const Color.fromRGBO(129, 129, 129, 0.2),
        const Color.fromRGBO(255, 255, 255, 0.2),
      ],
      stops: const [0.0, 0.4142, 1.0],
    );

    // Gradient for the background
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color.fromRGBO(214, 214, 214, 0.2),
        const Color.fromRGBO(112, 112, 112, 0.2),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        decoration: BoxDecoration(
          // Outer shadows
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000), // #0000001A
              offset: Offset(0, 8.15.h),
              blurRadius: 18.21.r,
            ),
            BoxShadow(
              color: const Color(0x17000000), // #00000017
              offset: Offset(0, 33.07.h),
              blurRadius: 33.07.r,
            ),
            BoxShadow(
              color: const Color(0x0D000000), // #0000000D
              offset: Offset(0, 74.76.h),
              blurRadius: 45.05.r,
            ),
            BoxShadow(
              color: const Color(0x03000000), // #00000003
              offset: Offset(0, 132.74.h),
              blurRadius: 53.19.r,
            ),
          ],
          borderRadius: BorderRadius.circular(109.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(109.r),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8.6, sigmaY: 8.6),
            child: CustomPaint(
              painter: _GradientPillBorderPainter(
                gradient: borderGradient,
                width: 1.1,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: backgroundGradient,
                  borderRadius: BorderRadius.circular(109.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReject
                            ? const Color(0xFFFF453A).withOpacity(0.2)
                            : Colors.white.withOpacity(0.2), // bg for icon
                      ),
                      child: Icon(
                        icon,
                        size: 14.sp,
                        color: isReject
                            ? const Color(0xFFFF453A)
                            : Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      text,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Samsung Sharp Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String svgPath,
    required VoidCallback onTap,
  }) {
    // Gradient for the border source
    // linear-gradient(180deg, rgba(242, 242, 242, 0.2) 0%, rgba(129, 129, 129, 0.2) 41.42%, rgba(255, 255, 255, 0.2) 100%)
    final borderGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color.fromRGBO(242, 242, 242, 0.2),
        const Color.fromRGBO(129, 129, 129, 0.2),
        const Color.fromRGBO(255, 255, 255, 0.2),
      ],
      stops: const [0.0, 0.4142, 1.0],
    );

    // Gradient for the background
    // linear-gradient(180deg, rgba(214, 214, 214, 0.2) -49.25%, rgba(112, 112, 112, 0.2) 123.88%)
    // Adjusting stops to 0 and 1 approximatively or keeping native
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color.fromRGBO(214, 214, 214, 0.2),
        const Color.fromRGBO(112, 112, 112, 0.2),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          // Outer shadows
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000), // #0000001A
              offset: Offset(0, 8.15.h),
              blurRadius: 18.21.r,
            ),
            BoxShadow(
              color: const Color(0x17000000), // #00000017
              offset: Offset(0, 33.07.h),
              blurRadius: 33.07.r,
            ),
            BoxShadow(
              color: const Color(0x0D000000), // #0000000D
              offset: Offset(0, 74.76.h),
              blurRadius: 45.05.r,
            ),
            BoxShadow(
              color: const Color(0x03000000), // #00000003
              offset: Offset(0, 132.74.h),
              blurRadius: 53.19.r,
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            109.r,
          ), // effectively circle for 38px
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8.6, sigmaY: 8.6),
            child: CustomPaint(
              painter: _GradientBorderPainter(
                gradient: borderGradient,
                width: 1.1,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: backgroundGradient,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(
                  12.w,
                ), // Adjust padding to fit icon inside
                child: SvgPicture.asset(svgPath, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double width;

  _GradientBorderPainter({required this.gradient, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    // Draw circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - width) / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradientPillBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double width;

  _GradientPillBorderPainter({required this.gradient, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.height / 2),
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension to avoid conflict if I placed class outside
// I will just put the class at the bottom of the file in the replacement.
