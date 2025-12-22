import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/personal_details_controller.dart';
import '../local_widgets/personal_details_form.dart';
import '../local_widgets/profile_picture_widget.dart';

class PersonalDetailsView extends GetView<PersonalDetailsController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            children: [
              TitleAppBar(text: 'Personal details'),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Center(
                        child: PersonalDetailsProfilePictureWidget(),
                      ),
                      SizedBox(height: 20.h),
                      PersonalDetailsForm(),
                      SizedBox(height: 40.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AppButton(
                        onTap: controller.handleNext,
                        text: 'next'.tr,
                        width: 350.w,
                        height: 48.h,
                      ),
                    ),
                      SizedBox(height: 20.h),
                  ],
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
