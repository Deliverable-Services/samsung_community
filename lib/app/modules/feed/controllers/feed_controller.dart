import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/create_post_modal.dart';
import '../../../data/helper_widgets/social_media_modal.dart';
import '../local_widgets/feed_action_modal.dart';

class FeedController extends GetxController {
  /// Controllers for create post modal
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  /// Show create post modal
  void showCreatePostModal() {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: CreatePostModal(
        titleController: titleController,
        descriptionController: descriptionController,
        onPublish: () {
          Navigator.of(Get.context!, rootNavigator: true).pop();
          showSocialMediaModal();
        },
      ),
    );
  }

  /// Show social media selection modal
  void showSocialMediaModal() {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        showCreatePostModal();
      },
      content: SocialMediaModal(
        onInstagramTap: () {
          debugPrint('Publishing to Instagram...');
        },
        onFacebookTap: () {
          debugPrint('Publishing to Facebook...');
        },
      ),
    );
  }

  /// Show feed action modal (delete/share)
  void showFeedActionModal(int postIndex) {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: FeedActionModal(
        postIndex: postIndex,
        onDelete: () {
          debugPrint('Delete post at index: $postIndex');
        },
        onShare: () {
          debugPrint('Share post at index: $postIndex');
        },
      ),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
