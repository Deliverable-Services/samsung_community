import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../controllers/academy_controller.dart';

class AcademicTextSubmitModule extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onPublish;
  final int? pointsToEarn;

  const AcademicTextSubmitModule({
    super.key,
    required this.title,
    required this.description,
    this.onPublish,
    this.pointsToEarn,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AcademyController>();

    return Obx(
      () => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Points
            Row(
              children: [
                SvgPicture.asset(
                  AppImages.pointsIcon,
                  width: 18.w,
                  height: 18.h,
                ),
                SizedBox(width: 4.w),
                Text(
                  "${pointsToEarn ?? 0}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            /// Title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textWhite,
              ),
            ),

            /// Description
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                color: AppColors.textWhite,
              ),
            ),

            SizedBox(height: 20.h),

            CustomTextField(
              label: 'text'.tr,
              controller: controller.textController,
              placeholder: 'type'.tr,
            ),

            SizedBox(height: 24.h),

            /// Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: controller.isConfirmChecked.value,
                  onChanged: (value) =>
                      controller.isConfirmChecked.value = value ?? false,
                  activeColor: AppColors.white,
                  checkColor: AppColors.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.isConfirmChecked.toggle(),
                    child: Text(
                      'iConfirmGranting'.tr,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            /// Submit Button (disabled until checked)
            AppButton(
              onTap: onPublish,
              text: 'submitAnswer'.tr,
              width: double.infinity,
              height: 48.h,
              isEnabled: controller.isConfirmChecked.value,
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicMcqSubmitModule extends StatefulWidget {
  final String title;
  final String description;
  final int? pointsToEarn;
  final List<dynamic> options;
  final ValueChanged<int> onSubmit;

  const AcademicMcqSubmitModule({
    super.key,
    required this.title,
    required this.description,
    required this.options,
    required this.onSubmit,
    this.pointsToEarn,
  });

  @override
  State<AcademicMcqSubmitModule> createState() =>
      _AcademicMcqSubmitModuleState();
}

class _AcademicMcqSubmitModuleState extends State<AcademicMcqSubmitModule> {
  final RxnInt selectedIndex = RxnInt();
  late final List<MapEntry<int, String>> _displayOptions;

  @override
  void initState() {
    super.initState();
    final list = <MapEntry<int, String>>[];
    for (var i = 0; i < widget.options.length; i++) {
      final m = widget.options[i];
      if (m is Map<String, dynamic> && m.containsKey('option')) {
        list.add(MapEntry(i, (m['option'] as Object?).toString().trim()));
      }
    }
    list.shuffle(Random());
    _displayOptions = list;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Points
            Row(
              children: [
                SvgPicture.asset(
                  AppImages.pointsIcon,
                  width: 18.w,
                  height: 18.h,
                ),
                SizedBox(width: 4.w),
                Text(
                  '+${widget.pointsToEarn ?? 0}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            /// Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),

            SizedBox(height: 4.h),

            /// Description
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textWhiteSecondary,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),

            SizedBox(height: 20.h),

            /// MCQ Options (correct_answer excluded; options shown in random order)
            ...List.generate(_displayOptions.length, (index) {
              final optionText = _displayOptions[index].value;

              return GestureDetector(
                onTap: () => selectedIndex.value = index,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      colors: selectedIndex.value == index
                          ? const [Color(0xFF3B82F6), Color(0xFF2563EB)]
                          : const [Color(0xFF3A3F45), Color(0xFF2F3439)],
                    ),
                  ),
                  child: Row(
                    children: [
                      _RadioCircle(isSelected: selectedIndex.value == index),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Samsung Sharp Sans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 24.h),

            /// Submit Button
            Opacity(
              opacity: selectedIndex.value != null ? 1 : 0.5,
              child: AppButton(
                text: 'submitAnswer'.tr,
                width: double.infinity,
                height: 48.h,
                onTap: selectedIndex.value != null
                    ? () => widget
                        .onSubmit(_displayOptions[selectedIndex.value!].key)
                    : null,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;

  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
