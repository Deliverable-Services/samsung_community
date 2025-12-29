import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samsung_community_mobile/app/common/services/supabase_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/constants/app_colors.dart';
import '../../data/core/utils/common_snackbar.dart';
import '../../data/core/utils/result.dart';
import '../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../data/helper_widgets/create_post_modal.dart';
import '../../data/models/content_model.dart';
import 'content_service.dart';
import 'storage_service.dart';

class CreatePostService {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final selectedMediaFile = Rxn<File>();
  final uploadedMediaUrl = Rxn<String>();
  final uploadedFileName = Rxn<String>();
  final isUploadingMedia = false.obs;

  Future<void> showCreatePostModal({
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) async {
    final context = Get.context;
    if (context == null) return;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: Obx(
        () => CreatePostModal(
          titleController: titleController,
          descriptionController: descriptionController,
          onPublish1: selectMediaFile,
          onRemoveFile: () {
            selectedMediaFile.value = null;
            uploadedMediaUrl.value = null;
            uploadedFileName.value = null;
          },
          selectedMediaFile: selectedMediaFile.value,
          uploadedMediaUrl: uploadedMediaUrl.value,
          uploadedFileName: uploadedFileName.value,
          isUploadingMedia: isUploadingMedia.value,
          onPublish: () async {
            if (titleController.text.trim().isEmpty &&
                descriptionController.text.trim().isEmpty) {
              Get.snackbar('Error', 'Please enter title or description');
              return;
            }

            Navigator.of(context, rootNavigator: true).pop();

            final user = SupabaseService.currentUser;
            if (user == null) {
              CommonSnackbar.error('User not found');
              onFailure();
              return;
            }

            final mediaUrl = uploadedMediaUrl.value ?? '';
            final isVideo =
                mediaUrl.toLowerCase().contains('.mp4') ||
                mediaUrl.toLowerCase().contains('.mov') ||
                mediaUrl.toLowerCase().contains('.avi');

            final data = {
              'title': titleController.text.trim(),
              'description': descriptionController.text.trim(),
              'content_type': ContentType.feed.toJson(),
              'user_id': user.id,
              'media_file_url': mediaUrl,
              'media_files': mediaUrl.isNotEmpty ? [mediaUrl] : [],
              'thumbnail_url': isVideo ? '' : mediaUrl,
              'category': '',
              'points_to_earn': 0,
              'is_featured': true,
              'is_published': true,
              'is_shared_to_community': true,
              'external_share_platforms': [],
              'view_count': 0,
              'likes_count': 0,
              'comments_count': 0,
            };

            final result = await ContentService().addContent(content: data);

            if (result is Success<Map<String, dynamic>>) {
              shareToInstagram(
                mediaPath: selectedMediaFile.value?.path ?? '',
                caption:
                    "${titleController.text}\n${descriptionController.text}",
              );
              clearFields();
              CommonSnackbar.success('Post published successfully');
              onSuccess();
            } else {
              CommonSnackbar.error('Failed to publish post');
              onFailure();
            }
          },
        ),
      ),
    );
  }

  ///Instagram opens → user selects Feed / Reel / Story
  Future<void> shareToInstagram({
    required String mediaPath, // local file path
    required String caption,
  }) async {
    // Copy caption
    await Clipboard.setData(ClipboardData(text: caption));

    // Share media
    await Share.shareXFiles([XFile(mediaPath)], text: caption);
  }

  /// Share Image / Video + Text (Facebook app)
  Future<void> shareToFacebook({
    required String mediaPath,
    required String text,
  }) async {
    await Share.shareXFiles([XFile(mediaPath)], text: text);
  }

  ///Facebook Text Post
  Future<void> shareTextFacebook(String text) async {
    final Uri uri = Uri.parse(
      "https://www.facebook.com/sharer/sharer.php?u=&quote=${Uri.encodeComponent(text)}",
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> selectMediaFile() async {
    try {
      final source = await _showMediaSourceDialog();
      if (source == null) return;

      final mediaType = await _showMediaTypeDialog();
      if (mediaType == null) return;

      XFile? pickedFile;
      if (mediaType == MediaType.image) {
        pickedFile = await StorageService.pickImage(source: source);
      } else {
        pickedFile = await StorageService.pickVideo(source: source);
      }

      if (pickedFile != null) {
        selectedMediaFile.value = File(pickedFile.path);
        uploadedFileName.value = pickedFile.name;
        await _uploadMediaFile();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to select file');
    }
  }

  Future<ImageSource?> _showMediaSourceDialog() async {
    return await Get.dialog<ImageSource>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.white,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: const Text(
                  'Take Photo/Video',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<MediaType?> _showMediaTypeDialog() async {
    return await Get.dialog<MediaType>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: AppColors.white),
                title: const Text(
                  'Image',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: MediaType.image),
              ),
              ListTile(
                leading: const Icon(
                  Icons.video_library,
                  color: AppColors.white,
                ),
                title: const Text(
                  'Video',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: MediaType.video),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadMediaFile() async {
    if (selectedMediaFile.value == null) return;

    isUploadingMedia.value = true;
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('User not found');
        return;
      }

      final file = selectedMediaFile.value!;
      final isVideo =
          file.path.toLowerCase().endsWith('.mp4') ||
          file.path.toLowerCase().endsWith('.mov') ||
          file.path.toLowerCase().endsWith('.avi');

      final mediaType = isVideo ? MediaType.video : MediaType.image;
      final url = await StorageService.uploadMedia(
        mediaFile: file,
        userId: currentUser.id,
        bucketName: 'content',
        mediaType: mediaType,
      );

      if (url != null) {
        uploadedMediaUrl.value = url;
      } else {
        CommonSnackbar.error('Failed to upload file');
        selectedMediaFile.value = null;
        uploadedFileName.value = null;
      }
    } catch (e) {
      debugPrint('Error uploading media: $e');
      CommonSnackbar.error('Failed to upload file');
      selectedMediaFile.value = null;
      uploadedFileName.value = null;
    } finally {
      isUploadingMedia.value = false;
    }
  }

  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    selectedMediaFile.value = null;
    uploadedMediaUrl.value = null;
    uploadedFileName.value = null;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}
