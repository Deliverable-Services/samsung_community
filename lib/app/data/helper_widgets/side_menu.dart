import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/app_pages.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../constants/language_options.dart';
import '../localization/language_controller.dart';
import '../../repository/auth_repo/auth_repo.dart';
import '../../common/controllers/unread_controller.dart';
import 'bottom_sheet_modal.dart';
import 'option_item.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  static void show(BuildContext context) {
    BottomSheetModal.show(
      context,
      content: const SideMenu(),
      buttonType: BottomSheetButtonType.close,
    );
  }

  void _handleMessages(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Get.toNamed(Routes.MESSAGES);
  }

  void _handleStore(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Get.toNamed(Routes.STORE);
  }

  Future<void> _handleSamsungStore(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop();
    final Uri url = Uri.parse('https://www.samsung.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _handleProfile(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Get.toNamed(Routes.PROFILE);
  }

  void _handleLanguage(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    _showLanguageSelector(context);
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    _showLogoutConfirmation(context);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.overlayContainerBackground,
          title: Text(
            'logout'.tr,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'wantLogout'.tr,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'no'.tr,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performLogout();
              },
              child: Text(
                'yes'.tr,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      final authRepo = Get.find<AuthRepo>();
      await authRepo.signOut();
    } catch (e) {
      debugPrint('Error during logout: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _showLanguageSelector(BuildContext context) {
    BottomSheetModal.show(
      context,
      onClose: () => SideMenu.show(context),
      buttonType: BottomSheetButtonType.back,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: LanguageOptions.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isLast = index == LanguageOptions.options.length - 1;
          final languageController = Get.find<LanguageController>();
          final isSelected = languageController.currentLocale == option.locale;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 10.h : 15.h),
            child: OptionItem(
              text: option.name,
              boxText: option.boxText,
              isSelected: isSelected,
              onTap: () async {
                languageController.changeLanguage(option.id);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final unreadController = Get.find<UnreadController>();
          return OptionItem(
            text: 'messages'.tr,
            badgeCount: unreadController.totalUnreadCount.value,
            boxTextWidget: SvgPicture.asset(
              AppImages.messagesIcon,
              width: 14.w,
              height: 14.h,
              fit: BoxFit.contain,
            ),
            onTap: () => _handleMessages(context),
          );
        }),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'store'.tr,
          boxTextWidget: SvgPicture.asset(
            AppImages.storeIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          onTap: () => _handleStore(context),
        ),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'samsungStore'.tr,
          boxTextWidget: SvgPicture.asset(
            AppImages.sIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          onTap: () => _handleSamsungStore(context),
        ),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'profile'.tr,
          boxTextWidget: SvgPicture.asset(
            AppImages.userIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          onTap: () => _handleProfile(context),
        ),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'language'.tr,
          boxTextWidget: SvgPicture.asset(
            AppImages.languageIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          onTap: () => _handleLanguage(context),
        ),
        SizedBox(height: 15.h),
        OptionItem(
          text: 'logout'.tr,
          boxText: 'L',
          onTap: () => _handleLogout(context),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
