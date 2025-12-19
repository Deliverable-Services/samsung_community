import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/services/content_service.dart';
import '../../../common/services/storage_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/create_post_modal.dart';
import '../../../data/helper_widgets/social_media_modal.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/user_model copy.dart';
import '../local_widgets/feed_action_modal.dart';

class FeedController extends BaseController {
  /// Controllers for create post modal
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final ContentService _contentService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<ContentModel> contentList = <ContentModel>[].obs;
  final RxList<ContentModel> filteredContentList = <ContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;

  final selectedImagePath = Rxn<File>();
  final profilePictureUrl = Rxn<String>();
  final isUploadingImage = false.obs;

  FeedController({ContentService? contentService})
    : _contentService = contentService ?? ContentService();

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  void setFilter(int index) {
    selectedFilterIndex.value = index;
    loadContent();
  }

  Future<Result<UserModel?>> getUserDetail(String userId) async {
    final response = await SupabaseService.client
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (response != null) {
      return Success(UserModel.fromJson(response));
    } else {
      return const Success(null);
    }
  }

  void onReadMore({required String title, required String description}) {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HEADER WITH CLOSE BUTTON
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// CONTENT
          Container(
            height: Get.height * .6,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.7,
                  color: AppColors.textWhiteOpacity70,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Future<void> loadContent() async {
    isLoadingContent.value = true;
    setLoading(true);

    try {
      final result = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );

      if (result.isSuccess) {
        contentList.value = result.dataOrNull ?? [];

        final futures = contentList.value.map((content) async {
          final userResult = await getUserDetail(content.userId);

          if (userResult is Success<UserModel?>) {
            return content.copyWith(userModel: userResult.data);
          }
          return content;
        }).toList();

        final updatedList = await Future.wait(futures);

        contentList.value = updatedList;
        filteredContentList.value = updatedList; // 👈 important
      } else {
        handleError(result.errorOrNull ?? 'somethingWentWrong'.tr);
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      isLoadingContent.value = false;
      setLoading(false);
    }
  }

  void onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      filteredContentList.value = contentList;
      return;
    }

    final lowerQuery = query.toLowerCase();

    filteredContentList.value = contentList.where((content) {
      return (content.title ?? '').toLowerCase().contains(lowerQuery) ||
          (content.description ?? '').toLowerCase().contains(lowerQuery) ||
          (content.userModel?.fullName ?? '').toLowerCase().contains(
            lowerQuery,
          );
    }).toList();
  }

  List<ContentModel> get filteredContent {
    if (selectedFilterIndex.value == 0) {
      return contentList;
    }
    return contentList;
  }

  Future<void> selectProfilePicture() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await StorageService.pickImage(source: source);
      if (pickedFile != null) {
        selectedImagePath.value = File(pickedFile.path);
        await _uploadProfilePicture();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to select image');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
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
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: Text(
                  'Take Photo',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    if (selectedImagePath.value == null) return;

    isUploadingImage.value = true;
    try {
      final user = SupabaseService.currentUser;
      final url = await StorageService.uploadProfilePicture(
        imageFile: selectedImagePath.value!,
        userId: user?.id ?? '',
        bucketName: 'profile_pictures',
      );

      if (url != null) {
        profilePictureUrl.value = url;
        print('profilePictureUrl.value::::::::${profilePictureUrl.value}');
      } else {
        CommonSnackbar.error('Failed to upload profile picture');
        selectedImagePath.value = null;
      }
    } catch (e) {
      CommonSnackbar.error('Failed to upload profile picture');
      selectedImagePath.value = null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Show create post modal
  /// Show create post modal
  void showCreatePostModal() {
    final context = Get.context!;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: CreatePostModal(
        titleController: titleController,
        descriptionController: descriptionController,
        onPublish1: selectProfilePicture,
        onPublish: () async {
          /// 🛑 Validation
          if (titleController.text.trim().isEmpty &&
              descriptionController.text.trim().isEmpty) {
            Get.snackbar('Error', 'Please enter title or description');
            return;
          }

          /// Close modal safely
          Navigator.of(context, rootNavigator: true).pop();

          final user = SupabaseService.currentUser;

          final data = {
            'title': titleController.text.trim(),
            'description': descriptionController.text.trim(),
            'content_type': ContentType.feed.toJson(),
            'user_id': user?.id ?? '',
            'media_file_url': '',
            'media_files': [],
            'thumbnail_url': '',
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
            /// ✅ Clear fields after success
            _clearCreatePostFields();

            /// Optional: reload feed
            loadContent();

            /// Show next modal
            showSocialMediaModal();
          } else {
            Get.snackbar('Error', 'Failed to publish post');
          }
        },
      ),
    );
  }

  void _clearCreatePostFields() {
    titleController.clear();
    descriptionController.clear();
    selectedImagePath.value = null; // if using Rx<File?>
    profilePictureUrl.value = null; // if using Rx<File?>
  }

  /// Show social media selection modal
  void showSocialMediaModal() {
    String? id;
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        showCreatePostModal();
      },
      content: SocialMediaModal(
        onInstagramTap: () async {
          debugPrint('Publishing to Instagram...');
          if (id != null) {
            await _contentService.updateContent(
              id,
              externalSharePlatforms: ['INSTAGRAM'],
            );
          }
        },
        onFacebookTap: () async {
          debugPrint('Publishing to Facebook...');
          if (id != null) {
            await _contentService.updateContent(
              id,
              externalSharePlatforms: ['FACEBOOK'],
            );
          }
        },
      ),
    );
  }

  /// Show feed action modal (delete/share)
  void showFeedActionModal(String? id) {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: FeedActionModal(
        onDelete: () {
          debugPrint('Delete post at index: $id');
          Get.back(); // close bottom sheet / menu
          if (id != null) {
            deleteContent(id);
            onInit();
          }
        },
        onShare: () {
          debugPrint('Share post at index: $id');
        },
      ),
    );
  }

  Future<void> deleteContent(String contentId) async {
    try {
      setLoading(true);

      final result = await _contentService.deleteContent(contentId);

      if (result.isSuccess) {
        /// Remove locally (no reload needed)
        contentList.removeWhere((item) => item.id == contentId);
        filteredContentList.removeWhere((item) => item.id == contentId);

        // Get.snackbar('Success', 'Post deleted successfully');
      } else {
        handleError(result.errorOrNull ?? 'Failed to delete post');
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
