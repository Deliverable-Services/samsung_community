import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class FilterTablet extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isSelected;

  const FilterTablet({
    super.key,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.only(right: 31.w, left: 31.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                  stops: [0.0041, 1.0042],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.buttonGradientStartLight,
                    AppColors.buttonGradientEndLight,
                  ],
                  stops: [0.0, 1.0],
                ),
          border: isSelected
              ? Border.all(
                  width: 1,
                  color: AppColors.textWhite.withOpacity(0.2),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 7.43),
              blurRadius: 16.6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              offset: const Offset(0, 30.15),
              blurRadius: 30.15,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 68.16),
              blurRadius: 41.07,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              offset: const Offset(0, 121.02),
              blurRadius: 48.5,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.0),
              offset: const Offset(0, 189.18),
              blurRadius: 52.87,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: SizedBox(
            child: Stack(
              children: [
                // Main content
                Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 14.sp,
                        height: 24 / 14,
                        letterSpacing: 0,
                        color: AppColors.white,
                      ),
                    ),
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

class FilterItem {
  final String text;
  final VoidCallback? onTap;
  final bool isSelected;

  const FilterItem({required this.text, this.onTap, this.isSelected = false});
}

class SearchWidget extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchWidget({
    super.key,
    required this.placeholder,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358.w,
      height: 50.h,
      padding: EdgeInsets.only(top: 13.h, right: 0.w, bottom: 13.h, left: 19.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment(-1.0, 0.0), // approx 273.57deg
          end: Alignment(1.0, 0.0),
          colors: [AppColors.searchGradientStart, AppColors.searchGradientEnd],
          stops: [0, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          child: Row(
            children: [
              // Search image
              Image.asset(
                AppImages.searchIcon,
                width: 22.20155143737793.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 13.w), // gap between search and label
              // Input field
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontStyle: FontStyle.normal,
                    fontSize: 14.sp,
                    height: 24 / 14,
                    letterSpacing: 0,
                    color: AppColors.white.withOpacity(0.4),
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontStyle: FontStyle.normal,
                      fontSize: 14.sp,
                      height: 24 / 14,
                      letterSpacing: 0,
                      color: AppColors.white.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterComponent extends StatelessWidget {
  final List<FilterItem> filterItems;

  const FilterComponent({super.key, required this.filterItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchWidget(placeholder: 'filterExploreLibrary'.tr),
        SizedBox(height: 20.h),
        // mainContainer2
        Row(
          children: [
            for (int i = 0; i < filterItems.length; i++) ...[
              FilterTablet(
                text: filterItems[i].text,
                onTap: filterItems[i].onTap,
                isSelected: filterItems[i].isSelected,
              ),
              if (i < filterItems.length - 1) SizedBox(width: 10.w),
            ],
          ],
        ),
      ],
    );
  }
}
