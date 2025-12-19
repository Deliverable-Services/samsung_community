import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class CustomDropDown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final ValueNotifier<T?> valueNotifier;
  final String hintText;
  final double borderRadius;
  final void Function(T?)? onChanged;

  final Color borderColor;

  const CustomDropDown({
    super.key,
    required this.items,
    required this.valueNotifier,
    this.borderRadius = 16,
    required this.hintText,
    this.borderColor = AppColors.primary,

    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius.r),
      borderSide: BorderSide(color: borderColor),
    );
    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (context, currentValue, child) {
        // If dropdown is disabled, always use null
        T? validValue = onChanged == null ? null : currentValue;

        // Treat empty string as null
        if (validValue is String && validValue.isEmpty) {
          validValue = null;
        }

        // Ensure the value exists in items, otherwise set to null
        if (validValue != null && items.isNotEmpty) {
          final valueExists = items.any((item) => item.value == validValue);
          if (!valueExists) {
            validValue = null;
            // Update the notifier to null if value is invalid (but only if it's not already null to avoid loops)
            if (valueNotifier.value != null && onChanged != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (valueNotifier.value is String &&
                    (valueNotifier.value as String).isEmpty) {
                  valueNotifier.value = null;
                } else if (valueNotifier.value != null) {
                  final exists = items.any(
                    (item) => item.value == valueNotifier.value,
                  );
                  if (!exists) {
                    valueNotifier.value = null;
                  }
                }
              });
            }
          }
        }

        return Container(
          width: 350.w,
          // height: 48.h,
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
                color: const Color(0x40000000),
                offset: Offset(2.w, -2.h),
                blurRadius: 2.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                left: 18,
                right: 8,
                top: 14,
                bottom: 14,
              ),
              enabledBorder: border,
              focusedBorder: border,
              fillColor: AppColors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: validValue,
                hint: Text(
                  hintText,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((DropdownMenuItem<T> item) {
                    // Extract text from the item's child widget
                    String text = '';
                    if (item.child is Text) {
                      text = (item.child as Text).data ?? '';
                    }

                    // Return white text for selected value display
                    return Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }).toList();
                },
                onChanged: onChanged,
                items: items,
                isDense: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
