import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helper_widgets/profile_picture_widget.dart';
import '../controllers/personal_details_controller.dart';

class PersonalDetailsProfilePictureWidget
    extends GetView<PersonalDetailsController> {
  const PersonalDetailsProfilePictureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProfilePictureWidget(
        imageFile: controller.selectedImagePath.value,
        imageUrl: controller.profilePictureUrl.value,
        isLoading: controller.isUploadingImage.value,
        onTap: controller.selectProfilePicture,
        showAddText: true,
        showAddIcon: true,
      );
    });
  }
}
