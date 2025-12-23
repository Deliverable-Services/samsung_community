import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/edit_profile_controller.dart';
import '../local_widgets/edit_profile_header.dart';
import '../local_widgets/edit_profile_picture.dart';
import '../local_widgets/edit_profile_tab_content.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(text: '', isLeading: false),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            EditProfileHeader(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: [
                      if (controller.selectedTab.value == 0) ...[
                        SizedBox(height: 20.h),
                        const EditProfilePicture(),
                        SizedBox(height: 20.h),
                      ],
                      const EditProfileTabContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
