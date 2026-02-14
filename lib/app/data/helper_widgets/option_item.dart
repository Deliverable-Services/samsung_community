import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class OptionItem extends StatefulWidget {
  final String? text;
  final Widget? textWidget;
  final String? boxText;
  final Widget? boxTextWidget;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? badgeCount;

  const OptionItem({
    super.key,
    this.text,
    this.textWidget,
    this.boxText,
    this.boxTextWidget,
    this.isSelected = false,
    this.onTap,
    this.badgeCount,
  }) : assert(
         (text != null || textWidget != null) &&
             (boxText != null || boxTextWidget != null),
         'Either text or textWidget must be provided, and either boxText or boxTextWidget must be provided',
       );

  @override
  State<OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onPointerUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onPointerCancel: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: _isPressed ? 0.6 : 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: _isPressed
                  ? AppColors.white.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 24.w,
                      // height: 24.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.2),
                            Color.fromRGBO(112, 112, 112, 0.2),
                          ],
                          stops: [0.0, 1.0],
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 3.57.h),
                            blurRadius: 7.97.r,
                            spreadRadius: 0,
                            color: AppColors.optionBoxShadow,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child:
                              widget.boxTextWidget ??
                              (widget.boxText != null
                                  ? ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.optionTextGradientStart,
                                              AppColors.optionTextGradientEnd,
                                            ],
                                            stops: [0.0, 1.0],
                                          ).createShader(bounds),
                                      child: Text(
                                        widget.boxText!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.sp,
                                          letterSpacing: 0,
                                          color: Colors.white,
                                          height: 1,
                                          fontFamily: 'Samsung Sharp Sans',
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      ),
                    ),
                    if (widget.badgeCount != null && widget.badgeCount! > 0)
                      Positioned(
                        top: -5.h,
                        right: -5.w,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: AppColors.unfollowPink,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 14.w,
                            minHeight: 14.w,
                          ),
                          child: Center(
                            child: Text(
                              widget.badgeCount!.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                height: 1,
                                fontFamily: 'Samsung Sharp Sans',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child:
                      widget.textWidget ??
                      Text(
                        widget.text ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          letterSpacing: 0,
                          color: AppColors.white,
                          height: 1,
                          fontFamily: 'Samsung Sharp Sans',
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
