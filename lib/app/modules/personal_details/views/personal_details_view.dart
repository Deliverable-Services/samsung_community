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
    final appBarHeight = TitleAppBar(
      text: 'Personal details',
    ).preferredSize.height;
    final totalOffset = appBarHeight + 20.h;

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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(color: Colors.transparent),
                    ProfilePictureWidget(
                      topOffset: 72.h,
                      totalOffset: totalOffset,
                    ),
                    Obx(() {
                      final hasImage =
                          controller.selectedImagePath.value != null ||
                          controller.profilePictureUrl.value != null;
                      return hasImage
                          ? const SizedBox.shrink()
                          : AddIconWidget(
                              topOffset: 98.h,
                              totalOffset: totalOffset,
                            );
                    }),
                    PersonalDetailsForm(
                      topOffset: 231.43.h,
                      totalOffset: totalOffset,
                    ),
                    Positioned(
                      top: 807.h - totalOffset,
                      left: 20.w,
                      child: AppButton(
                        onTap: controller.handleNext,
                        text: 'next'.tr,
                        width: 350.w,
                        height: 48.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
