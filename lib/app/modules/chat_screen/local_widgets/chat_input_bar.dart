import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/chat_screen_controller.dart';

class ChatInputBar extends StatelessWidget {
  final ChatScreenController controller;

  const ChatInputBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.inputGradientStart, AppColors.inputGradientEnd],
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40000000),
              offset: Offset(2.w, -2.h),
              blurRadius: 2.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 22 / 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'messagePlaceholder'.tr,
                  hintStyle: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    letterSpacing: 0,
                    color: AppColors.white.withOpacity(0.3),
                    height: 22 / 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20.w,
                  ),
                ),
              ),
            ),
            Obx(() {
              return GestureDetector(
                onTap: controller.isSending.value
                    ? null
                    : controller.sendMessage,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: controller.isSending.value
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.linkBlue,
                            ),
                          ),
                        )
                      : Text(
                          'send'.tr,
                          style: TextStyle(
                            fontFamily: 'Samsung Sharp Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            letterSpacing: 0,
                            color: AppColors.linkBlue,
                            height: 22 / 14,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
