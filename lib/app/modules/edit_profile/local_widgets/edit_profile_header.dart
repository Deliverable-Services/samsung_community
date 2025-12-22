import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'edit_profile_tab_button.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileHeader extends StatelessWidget {
  final EditProfileController controller;

  const EditProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: EditProfileTabButton(
              text: 'personalDetails'.tr,
              index: 0,
              controller: controller,
            ),
          ),
          Expanded(
            child: EditProfileTabButton(
              text: 'accountDetails'.tr,
              index: 1,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
