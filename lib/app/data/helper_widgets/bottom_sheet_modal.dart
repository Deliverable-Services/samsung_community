import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import 'back_button.dart';
import 'close_button.dart';

enum BottomSheetButtonType { back, close, none }

class BottomSheetModal extends StatelessWidget {
  final Widget content;
  final VoidCallback? onClose;
  final BottomSheetButtonType buttonType;

  const BottomSheetModal({
    super.key,
    required this.content,
    this.onClose,
    this.buttonType = BottomSheetButtonType.back,
  });

  static void show(
    BuildContext context, {
    required Widget content,
    VoidCallback? onClose,
    bool? isScrollControlled,
    BottomSheetButtonType buttonType = BottomSheetButtonType.back,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled ?? true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets, // 🔥 REQUIRED
        child: BottomSheetModal(
          content: content,
          onClose: onClose,
          buttonType: buttonType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: GestureDetector(
        onTap: () {}, // Prevent tap from closing when tapping inside modal
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.overlayContainerBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -6.h),
                blurRadius: 50.r,
                spreadRadius: 0,
                color: AppColors.overlayContainerShadow,
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 14.w),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 19.h,
                  left: 20.w,
                  right: 20.w,
                  bottom: 20.h,
                ),
                child: content,
              ),
              Positioned(
                top: 0.w,
                right: 20.w,
                child: buttonType == BottomSheetButtonType.none
                    ? const SizedBox.shrink()
                    : buttonType == BottomSheetButtonType.close
                    ? CustomCloseButton(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          onClose?.call();
                        },
                      )
                    : CustomBackButton(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          onClose?.call();
                        },
                        rotation: 0,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
