import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/services/content_service.dart';
import '../../../common/services/content_interaction_service.dart';
import '../../../common/services/storage_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/social_media_modal.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/user_model copy.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../feed/local_widgets/comments_modal.dart';
import '../../feed/local_widgets/feed_action_modal.dart';

class ProfileController extends BaseController {
  final ContentService _contentService;
  final ContentInteractionService _interactionService;
  final AuthRepo _authRepo;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<ContentModel> postsList = <ContentModel>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxMap<String, bool> likedStatusMap = <String, bool>{}.obs;
  final RxMap<String, List<UserModel>> likedByUsersMap =
      <String, List<UserModel>>{}.obs;

  int postsCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool _isDeleting = false;
  DateTime? _lastRefreshTime;

  ProfileController({
    ContentService? contentService,
    ContentInteractionService? interactionService,
    AuthRepo? authRepo,
  }) : _contentService = contentService ?? ContentService(),
       _interactionService = interactionService ?? ContentInteractionService(),
       _authRepo = authRepo ?? Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadUserPosts();
  }

  @override
  void onReady() {
    super.onReady();
    refreshProfileData();
  }

  Future<void> refreshProfileData() async {
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inSeconds < 2) {
      return;
    }
    _lastRefreshTime = now;
    await _authRepo.loadCurrentUser();
    await loadUserProfile();
    await loadUserPosts();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadUserProfile() async {
    try {
      setLoading(true);
      final currentUser = _authRepo.currentUser.value;
      if (currentUser != null) {
        final userJson = currentUser.toJson();
        user.value = UserModel.fromJson(userJson);
        await _loadUserStats();
      }
    } catch (e) {
      handleError('Failed to load profile');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _loadUserStats() async {
    isLoadingStats.value = true;
    try {
      final userId = user.value?.id;
      if (userId == null) {
        isLoadingStats.value = false;
        return;
      }

      final postsResult = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );

      if (postsResult.isSuccess) {
        final allPosts = postsResult.dataOrNull ?? [];
        postsCount = allPosts.where((p) => p.userId == userId).length;
      }

      final followersResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('following_id', userId);

      followersCount = (followersResult as List).length;

      final followingResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', userId);

      followingCount = (followingResult as List).length;
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadUserPosts() async {
    isLoadingPosts.value = true;
    setLoading(true);

    try {
      final userId = _authRepo.currentUser.value?.id;
      if (userId == null) {
        isLoadingPosts.value = false;
        setLoading(false);
        return;
      }

      final result = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );

      if (result.isSuccess) {
        final allContent = result.dataOrNull ?? [];
        final userPosts = allContent.where((c) => c.userId == userId).toList();

        final futures = userPosts.map((content) async {
          final userResult = await _getUserDetail(content.userId);
          if (userResult is Success<UserModel?>) {
            final userModel = userResult.data;
            if (userModel != null) {
              return content.copyWith(userModel: userModel);
            }
          }
          return content;
        }).toList();

        final updatedList = await Future.wait(futures);
        postsList.value = updatedList;

        final currentUserId = SupabaseService.currentUser?.id;
        if (currentUserId != null) {
          await _loadLikedStatuses(updatedList, currentUserId);
          await _loadLikedByUsers(updatedList);
        }
      } else {
        handleError(result.errorOrNull ?? 'somethingWentWrong'.tr);
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      isLoadingPosts.value = false;
      setLoading(false);
    }
  }

  Future<Result<UserModel?>> _getUserDetail(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('id', userId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response != null) {
        return Success(UserModel.fromJson(response));
      } else {
        return const Success(null);
      }
    } catch (e) {
      return Failure(e.toString());
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
      final result = await _interactionService.getLikedByUsers(
        contentId: content.id,
      );
      if (result.isSuccess) {
        final users = result.dataOrNull ?? [];
        likedByUsersMap[content.id] = users.cast<UserModel>();
      }
    }
  }

  bool isLiked(String contentId) {
    return likedStatusMap[contentId] ?? false;
  }

  List<UserModel> getLikedByUsers(String contentId) {
    return likedByUsersMap[contentId] ?? [];
  }

  Future<void> toggleLike(String contentId) async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) return;

    final result = await _interactionService.toggleLike(
      contentId: contentId,
      userId: currentUser.id,
    );

    if (result.isSuccess) {
      final isLikedNow = result.dataOrNull ?? false;
      likedStatusMap[contentId] = isLikedNow;

      final post = postsList.firstWhereOrNull((p) => p.id == contentId);
      if (post != null) {
        final index = postsList.indexOf(post);
        postsList[index] = post.copyWith(
          likesCount: isLikedNow
              ? post.likesCount + 1
              : (post.likesCount > 0 ? post.likesCount - 1 : 0),
        );
      }

      await _loadLikedByUsers([post!]);
    } else {
      CommonSnackbar.error(result.errorOrNull ?? 'Failed to like post');
    }
  }

  Future<void> addComment(String contentId, String commentText) async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) return;

    final result = await _interactionService.addComment(
      contentId: contentId,
      userId: currentUser.id,
      commentText: commentText,
    );

    if (result.isSuccess) {
      final post = postsList.firstWhereOrNull((p) => p.id == contentId);
      if (post != null) {
        final index = postsList.indexOf(post);
        postsList[index] = post.copyWith(commentsCount: post.commentsCount + 1);
      }
      CommonSnackbar.success('Comment added');
    } else {
      CommonSnackbar.error(result.errorOrNull ?? 'Failed to add comment');
    }
  }

  void showCommentsModal(String contentId) {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: CommentsModal(
        contentId: contentId,
        onAddComment: (String commentId) {
          loadUserPosts();
        },
      ),
    );
  }

  void showFeedActionModal(String? id) {
    if (id == null) return;

    final content = postsList.firstWhereOrNull((c) => c.id == id);
    final currentUser = SupabaseService.currentUser;
    final isOwnPost =
        content != null &&
        currentUser != null &&
        content.userId == currentUser.id;

    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: FeedActionModal(
        isOwnPost: isOwnPost,
        onDelete: () {
          Get.back();
          deleteContent(id);
        },
        onShare: () {
          final shareContext = Get.context;
          if (shareContext != null &&
              Navigator.of(shareContext, rootNavigator: true).canPop()) {
            Navigator.of(shareContext, rootNavigator: true).pop();
          }
          Future.delayed(const Duration(milliseconds: 600), () {
            final context = Get.context;
            if (context != null) {
              showSocialMediaModal(id);
            }
          });
        },
      ),
    );
  }

  void showSocialMediaModal(String? contentId) {
    final context = Get.context;
    if (context == null) return;

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
    );
  }

  Future<void> deleteContent(String contentId) async {
    if (_isDeleting) return;

    try {
      _isDeleting = true;
      final result = await _contentService.deleteContent(contentId);

      if (result.isSuccess) {
        CommonSnackbar.success('Post deleted successfully');
        // Reload content after 1 second - loading will be handled by loadUserPosts
        Future.delayed(const Duration(seconds: 1), () {
          loadUserPosts();
          _loadUserStats();
        });
      } else {
        handleError(result.errorOrNull ?? 'Failed to delete post');
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      _isDeleting = false;
    }
  }

  Future<void> selectProfilePicture() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await StorageService.pickImage(source: source);
      if (pickedFile != null) {
        await _uploadProfilePicture(File(pickedFile.path));
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
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: const Text(
                  'Take Photo',
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

  Future<void> _uploadProfilePicture(File imageFile) async {
    final currentUser = _authRepo.currentUser.value;
    if (currentUser == null || currentUser.id.isEmpty) {
      CommonSnackbar.error('User not found');
      return;
    }

    isUploadingImage.value = true;
    try {
      final url = await StorageService.uploadProfilePicture(
        imageFile: imageFile,
        userId: currentUser.id,
        bucketName: 'profile_pictures',
      );

      if (url != null) {
        await _updateUserProfilePicture(url);
        CommonSnackbar.success('Profile picture updated');
      } else {
        CommonSnackbar.error('Failed to upload profile picture');
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      CommonSnackbar.error('Failed to upload profile picture');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _updateUserProfilePicture(String imageUrl) async {
    try {
      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) return;

      await SupabaseService.client
          .from('users')
          .update({'profile_picture_url': imageUrl})
          .eq('id', currentUser.id);

      final updatedUser = user.value;
      if (updatedUser != null) {
        final updatedJson = updatedUser.toJson();
        updatedJson['profile_picture_url'] = imageUrl;
        final updatedUserModel = UserModel.fromJson(updatedJson);
        user.value = updatedUserModel;
        await _authRepo.loadCurrentUser();
      }
    } catch (e) {
      debugPrint('Error updating user profile picture: $e');
      throw e;
    }
  }
}
