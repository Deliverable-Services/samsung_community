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
  final double? maxHeight;

  const BottomSheetModal({
    super.key,
    required this.content,
    this.onClose,
    this.buttonType = BottomSheetButtonType.back,
    this.maxHeight,
  });

  static void show(
    BuildContext context, {
    required Widget content,
    VoidCallback? onClose,
    bool? isScrollControlled,
    BottomSheetButtonType buttonType = BottomSheetButtonType.back,
    double? maxHeight,
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
          maxHeight: maxHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - bottomPadding - 120.h;

    final defaultMaxHeight = 905.h;
    final targetHeight = maxHeight ?? defaultMaxHeight;
    final effectiveMaxHeight =
        targetHeight > availableHeight ? availableHeight : targetHeight;

    return SafeArea(
      top: true,
      bottom: false,
      child: GestureDetector(
        onTap: () {}, // Prevent tap from closing when tapping inside modal
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                buttonType == BottomSheetButtonType.none
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
                const SizedBox(height: 10),
                Flexible(
                  child: content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
