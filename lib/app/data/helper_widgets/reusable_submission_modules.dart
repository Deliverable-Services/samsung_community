import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'custom_text_field.dart';
import 'read_more_text.dart';
import 'upload_file_field.dart';

/// Reusable Text Submission Module
/// Can be used for both academy assignments and weekly riddles
class ReusableTextSubmitModule extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onPublish;
  final int? pointsToEarn;
  final TextEditingController textController;
  final RxBool isConfirmChecked;

  const ReusableTextSubmitModule({
    super.key,
    required this.title,
    required this.description,
    this.onPublish,
    this.pointsToEarn,
    required this.textController,
    required this.isConfirmChecked,
  });

  @override
  Widget build(BuildContext context) {
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
            ReadMoreText(
              text: description,
              textStyle: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                color: AppColors.textWhite,
              ),
            ),

            SizedBox(height: 20.h),

            CustomTextField(
              label: 'text'.tr,
              controller: textController,
              placeholder: 'type'.tr,
            ),

            SizedBox(height: 10.h),

            /// Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isConfirmChecked.value,
                  onChanged: (value) => isConfirmChecked.value = value ?? false,
                  activeColor: AppColors.white,
                  checkColor: AppColors.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => isConfirmChecked.toggle(),
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

            SizedBox(height: 10.h),

            /// Submit Button (disabled until checked)
            AppButton(
              onTap: onPublish,
              text: 'submitAnswer'.tr,
              width: double.infinity,
              height: 48.h,
              isEnabled: isConfirmChecked.value,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Audio Submission Module
/// Can be used for both academy assignments and weekly riddles
class ReusableAudioSubmitModule extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onPublish;
  final VoidCallback? onPublish1;
  final VoidCallback? onRemove;
  final int? pointsToEarn;
  final RxBool isConfirmChecked;
  final Rxn<String> uploadedFileName;
  final RxBool isUploadingMedia;

  const ReusableAudioSubmitModule({
    super.key,
    required this.title,
    required this.description,
    this.onPublish,
    this.onPublish1,
    this.onRemove,
    this.pointsToEarn,
    required this.isConfirmChecked,
    required this.uploadedFileName,
    required this.isUploadingMedia,
  });

  @override
  Widget build(BuildContext context) {
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
            ReadMoreText(
              text: description,
              textStyle: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                color: AppColors.textWhite,
              ),
            ),

            SizedBox(height: 20.h),

            /// Upload file
            UploadFileField(
              onTap: onPublish1,
              onRemove: onRemove,
              uploadedFileName: uploadedFileName.value,
              isUploadingMedia: isUploadingMedia.value,
            ),

            SizedBox(height: 24.h),

            /// Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isConfirmChecked.value,
                  onChanged: (value) => isConfirmChecked.value = value ?? false,
                  activeColor: AppColors.white,
                  checkColor: AppColors.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => isConfirmChecked.toggle(),
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
              isEnabled: isConfirmChecked.value,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable MCQ Submission Module
/// Can be used for both academy assignments and weekly riddles
class ReusableMcqSubmitModule extends StatefulWidget {
  final String title;
  final String description;
  final int? pointsToEarn;
  final List<dynamic> options;
  final ValueChanged<int> onSubmit;

  const ReusableMcqSubmitModule({
    super.key,
    required this.title,
    required this.description,
    required this.options,
    required this.onSubmit,
    this.pointsToEarn,
  });

  @override
  State<ReusableMcqSubmitModule> createState() =>
      _ReusableMcqSubmitModuleState();
}

class _ReusableMcqSubmitModuleState extends State<ReusableMcqSubmitModule> {
  final RxnInt selectedIndex = RxnInt();

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
              ),
            ),

            SizedBox(height: 4.h),

            /// Description
            ReadMoreText(
              text: widget.description,
              textStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textWhiteSecondary,
              ),
            ),

            SizedBox(height: 20.h),

            /// MCQ Options
            ...List.generate(widget.options.length, (index) {
              final optionMap = widget.options[index];
              final optionText = (optionMap as Map<String, dynamic>)
                  .values
                  .first
                  .toString();

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
                    ? () => widget.onSubmit(selectedIndex.value!)
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
