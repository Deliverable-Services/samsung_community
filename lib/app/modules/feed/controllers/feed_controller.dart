import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/services/content_service.dart';
import '../../../common/services/content_interaction_service.dart';
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
import '../local_widgets/comments_modal.dart';

class FeedController extends BaseController {
  /// Controllers for create post modal
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final ContentService _contentService;
  final ContentInteractionService _interactionService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<ContentModel> contentList = <ContentModel>[].obs;
  final RxList<ContentModel> filteredContentList = <ContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxMap<String, bool> likedStatusMap = <String, bool>{}.obs;
  final RxMap<String, List<UserModel>> likedByUsersMap =
      <String, List<UserModel>>{}.obs;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  final selectedImagePath = Rxn<File>();
  final profilePictureUrl = Rxn<String>();
  final isUploadingImage = false.obs;
  final selectedMediaFile = Rxn<File>();
  final uploadedMediaUrl = Rxn<String>();
  final uploadedFileName = Rxn<String>();
  final isUploadingMedia = false.obs;
  bool _isOpeningSocialModal = false;

  FeedController({
    ContentService? contentService,
    ContentInteractionService? interactionService,
  }) : _contentService = contentService ?? ContentService(),
       _interactionService = interactionService ?? ContentInteractionService();

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  void setFilter(int index) {
    selectedFilterIndex.value = index;
    _currentOffset = 0;
    contentList.clear();
    filteredContentList.clear();
    hasMoreData.value = true;
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

  Future<void> loadContent({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMoreData.value) return;
      isLoadingMore.value = true;
    } else {
      _currentOffset = 0;
      contentList.clear();
      filteredContentList.clear();
      hasMoreData.value = true;
      isLoadingContent.value = true;
      setLoading(true);
    }

    try {
      final result = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
        limit: _pageSize,
        offset: loadMore ? _currentOffset : 0,
      );

      if (result.isSuccess) {
        final newContent = result.dataOrNull ?? [];

        final futures = newContent.map((content) async {
          final userResult = await getUserDetail(content.userId);

          if (userResult is Success<UserModel?>) {
            return content.copyWith(userModel: userResult.data);
          }
          return content;
        }).toList();

        final updatedList = await Future.wait(futures);

        if (loadMore) {
          contentList.addAll(updatedList);
        } else {
          contentList.value = updatedList;
        }

        filteredContentList.value = contentList;

        final currentUserId = SupabaseService.currentUser?.id;
        if (currentUserId != null) {
          await _loadLikedStatuses(updatedList, currentUserId);
          await _loadLikedByUsers(updatedList);
        }

        if (newContent.length < _pageSize) {
          hasMoreData.value = false;
        } else {
          _currentOffset = contentList.length;
        }
      } else {
        handleError(result.errorOrNull ?? 'somethingWentWrong'.tr);
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoadingContent.value = false;
        setLoading(false);
      }
    }
  }

  Future<void> loadMoreContent() async {
    await loadContent(loadMore: true);
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
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: Text(
                  'Take Photo/Video',
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
                leading: const Icon(
                  Icons.image,
                  color: AppColors.white,
                ),
                title: Text(
                  'Image',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: MediaType.image),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColors.white),
                title: Text(
                  'Video',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: MediaType.video),
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

  Future<void> _uploadMediaFile() async {
    if (selectedMediaFile.value == null) return;

    isUploadingMedia.value = true;
    try {
      final user = SupabaseService.currentUser;
      final file = selectedMediaFile.value!;
      final mediaType = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi')
          ? MediaType.video
          : MediaType.image;

      final url = await StorageService.uploadMedia(
        mediaFile: file,
        userId: user?.id ?? '',
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
      CommonSnackbar.error('Failed to upload file');
      selectedMediaFile.value = null;
      uploadedFileName.value = null;
    } finally {
      isUploadingMedia.value = false;
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
        onPublish1: selectMediaFile,
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

          final mediaUrl = uploadedMediaUrl.value ?? '';
          final isVideo = mediaUrl.toLowerCase().contains('.mp4') ||
              mediaUrl.toLowerCase().contains('.mov') ||
              mediaUrl.toLowerCase().contains('.avi');

          final data = {
            'title': titleController.text.trim(),
            'description': descriptionController.text.trim(),
            'content_type': ContentType.feed.toJson(),
            'user_id': user?.id ?? '',
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
            /// ✅ Clear fields after success
            _clearCreatePostFields();

            /// Optional: reload feed
            loadContent();

            CommonSnackbar.success('Post published successfully');
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
    selectedImagePath.value = null;
    profilePictureUrl.value = null;
    selectedMediaFile.value = null;
    uploadedMediaUrl.value = null;
    uploadedFileName.value = null;
  }

  /// Show social media selection modal
  void showSocialMediaModal(String? contentId) {
    if (_isOpeningSocialModal) {
      debugPrint('Social media modal is already opening');
      return;
    }

    final context = Get.context;
    if (context == null) {
      debugPrint('Context is null, cannot show social media modal');
      return;
    }

    _isOpeningSocialModal = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (modalContext) => Padding(
        padding: MediaQuery.of(modalContext).viewInsets,
        child: BottomSheetModal(
          content: SocialMediaModal(
            onInstagramTap: () async {
              if (Navigator.of(modalContext, rootNavigator: true).canPop()) {
                Navigator.of(modalContext, rootNavigator: true).pop();
              }
              _isOpeningSocialModal = false;
              debugPrint('Sharing to Instagram...');
              if (contentId != null) {
                await _contentService.updateContent(
                  contentId,
                  externalSharePlatforms: ['INSTAGRAM'],
                );
                CommonSnackbar.success('Shared to Instagram');
              }
            },
            onFacebookTap: () async {
              if (Navigator.of(modalContext, rootNavigator: true).canPop()) {
                Navigator.of(modalContext, rootNavigator: true).pop();
              }
              _isOpeningSocialModal = false;
              debugPrint('Sharing to Facebook...');
              if (contentId != null) {
                await _contentService.updateContent(
                  contentId,
                  externalSharePlatforms: ['FACEBOOK'],
                );
                CommonSnackbar.success('Shared to Facebook');
              }
            },
          ),
          buttonType: BottomSheetButtonType.close,
        ),
      ),
    ).then((_) {
      _isOpeningSocialModal = false;
    });
  }

  /// Show feed action modal (delete/share)
  void showFeedActionModal(String? id) {
    if (id == null) return;

    final content = contentList.firstWhereOrNull((c) => c.id == id);
    final currentUser = SupabaseService.currentUser;
    final isOwnPost = content != null &&
        currentUser != null &&
        content.userId == currentUser.id;

    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: FeedActionModal(
        isOwnPost: isOwnPost,
        onDelete: () {
          debugPrint('Delete post at index: $id');
          Get.back();
          deleteContent(id);
          onInit();
        },
        onShare: () {
          final shareContext = Get.context;
          if (shareContext != null &&
              Navigator.of(shareContext, rootNavigator: true).canPop()) {
            Navigator.of(shareContext, rootNavigator: true).pop();
          }
          Future.delayed(const Duration(milliseconds: 600), () {
            final context = Get.context;
            if (context != null && !_isOpeningSocialModal) {
              showSocialMediaModal(id);
            }
          });
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

  Future<void> _loadLikedStatuses(
    List<ContentModel> contents,
    String userId,
  ) async {
    for (final content in contents) {
      final result = await _interactionService.isLiked(
        contentId: content.id,
        userId: userId,
      );
      if (result.isSuccess) {
        likedStatusMap[content.id] = result.dataOrNull ?? false;
      }
    }
  }

  Future<void> _loadLikedByUsers(List<ContentModel> contents) async {
    for (final content in contents) {
      if (content.likesCount > 0) {
        final result = await _interactionService.getLikedByUsers(
          contentId: content.id,
          limit: 3,
        );
        if (result.isSuccess && result.dataOrNull != null) {
          likedByUsersMap[content.id] = result.dataOrNull!;
        }
      }
    }
  }

  Future<void> toggleLike(String contentId) async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null) {
      CommonSnackbar.error('Please login to like content');
      return;
    }

    try {
      final result = await _interactionService.toggleLike(
        contentId: contentId,
        userId: currentUserId,
      );

      if (result.isSuccess) {
        final isLiked = result.dataOrNull ?? false;
        likedStatusMap[contentId] = isLiked;

        final contentIndex = contentList.indexWhere((c) => c.id == contentId);
        if (contentIndex != -1) {
          final content = contentList[contentIndex];
          final newLikesCount = isLiked
              ? content.likesCount + 1
              : (content.likesCount > 0 ? content.likesCount - 1 : 0);

          contentList[contentIndex] = content.copyWith(
            likesCount: newLikesCount,
          );

          final filteredIndex = filteredContentList.indexWhere(
            (c) => c.id == contentId,
          );
          if (filteredIndex != -1) {
            filteredContentList[filteredIndex] = contentList[contentIndex];
          }

          if (isLiked) {
            await _loadLikedByUsers([contentList[contentIndex]]);
          }
        }
      } else {
        handleError(result.errorOrNull ?? 'Failed to like content');
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    }
  }

  Future<void> addComment(String contentId, String commentText) async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null) {
      CommonSnackbar.error('Please login to comment');
      return;
    }

    if (commentText.trim().isEmpty) {
      CommonSnackbar.error('Comment cannot be empty');
      return;
    }

    try {
      final result = await _interactionService.addComment(
        contentId: contentId,
        userId: currentUserId,
        commentText: commentText,
      );

      if (result.isSuccess) {
        final contentIndex = contentList.indexWhere((c) => c.id == contentId);
        if (contentIndex != -1) {
          final content = contentList[contentIndex];
          contentList[contentIndex] = content.copyWith(
            commentsCount: content.commentsCount + 1,
          );

          final filteredIndex = filteredContentList.indexWhere(
            (c) => c.id == contentId,
          );
          if (filteredIndex != -1) {
            filteredContentList[filteredIndex] = contentList[contentIndex];
          }
        }

        CommonSnackbar.success('Comment added successfully');
      } else {
        handleError(result.errorOrNull ?? 'Failed to add comment');
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    }
  }

  void showCommentsModal(String contentId) {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: CommentsModal(
        contentId: contentId,
        onAddComment: (commentText) => addComment(contentId, commentText),
      ),
    );
  }

  bool isLiked(String contentId) {
    return likedStatusMap[contentId] ?? false;
  }

  List<UserModel> getLikedByUsers(String contentId) {
    return likedByUsersMap[contentId] ?? [];
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
