import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/services/content_interaction_service.dart';
import '../../../common/services/content_service.dart';
import '../../../common/services/profile_service.dart';
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
  final ContentInteractionService _interactionService;
  final ContentService _contentService;
  final ProfileService _profileService;
  final AuthRepo _authRepo;

  final RxBool isUploadingImage = false.obs;

  bool _isDeleting = false;

  ProfileController({
    ContentInteractionService? interactionService,
    ContentService? contentService,
    ProfileService? profileService,
    AuthRepo? authRepo,
  }) : _interactionService = interactionService ?? ContentInteractionService(),
       _contentService = contentService ?? ContentService(),
       _profileService = profileService ?? Get.find<ProfileService>(),
       _authRepo = authRepo ?? Get.find<AuthRepo>();

  UserModel? get user => _profileService.user.value;
  Rx<UserModel?> get userRx => _profileService.user;
  RxList<ContentModel> get postsList => _profileService.postsList;
  RxBool get isLoadingPosts => _profileService.isLoadingPosts;
  RxBool get isLoadingStats => _profileService.isLoadingStats;
  int get postsCount => _profileService.postsCount.value;
  int get followersCount => _profileService.followersCount.value;
  int get followingCount => _profileService.followingCount.value;
  @override
  RxBool get isLoading =>
      (_profileService.isLoadingPosts.value ||
              _profileService.isLoadingStats.value)
          .obs;

  @override
  void onInit() {
    super.onInit();
    _profileService.loadUserProfile();
    _profileService.loadUserPosts();
  }

  @override
  void onReady() {
    super.onReady();
    _profileService.refreshProfileData();
  }

  Future<void> refreshProfileData() async {
    await _profileService.refreshProfileData();
  }

  Future<void> loadUserProfile() async {
    await _profileService.loadUserProfile();
  }

  Future<void> loadUserPosts() async {
    await _profileService.loadUserPosts();
  }

  bool isLiked(String contentId) {
    return _profileService.isLiked(contentId);
  }

  List<UserModel> getLikedByUsers(String contentId) {
    return _profileService.getLikedByUsers(contentId);
  }

  Future<void> toggleLike(String contentId) async {
    final currentUserSupabase = SupabaseService.currentUser;
    if (currentUserSupabase == null) return;

    final post = _profileService.postsList.firstWhereOrNull(
      (p) => p.id == contentId,
    );
    if (post == null) return;

    final previousIsLiked = _profileService.likedStatusMap[contentId] ?? false;
    final previousLikesCount = post.likesCount;
    final previousLikedByUsers = List<UserModel>.from(
      _profileService.likedByUsersMap[contentId] ?? [],
    );

    final newIsLiked = !previousIsLiked;
    _profileService.likedStatusMap[contentId] = newIsLiked;

    final index = _profileService.postsList.indexOf(post);
    final newLikesCount = newIsLiked
        ? previousLikesCount + 1
        : (previousLikesCount > 0 ? previousLikesCount - 1 : 0);

    _profileService.postsList[index] = post.copyWith(likesCount: newLikesCount);

    final currentUser = _authRepo.currentUser.value;
    if (currentUser != null && newIsLiked) {
      final existingLikedBy = _profileService.likedByUsersMap[contentId] ?? [];
      final userExists = existingLikedBy.any((u) => u.id == currentUser.id);
      if (!userExists) {
        final userJson = currentUser.toJson();
        final convertedUser = UserModel.fromJson(userJson);
        final updatedList = <UserModel>[convertedUser, ...existingLikedBy];
        _profileService.likedByUsersMap[contentId] = updatedList
            .take(3)
            .toList();
      }
    } else if (!newIsLiked) {
      final existingLikedBy = _profileService.likedByUsersMap[contentId] ?? [];
      _profileService.likedByUsersMap[contentId] = existingLikedBy
          .where((u) => u.id != currentUserSupabase.id)
          .toList();
    }

    _interactionService
        .toggleLike(contentId: contentId, userId: currentUserSupabase.id)
        .then((result) async {
          if (result.isSuccess) {
            final serverIsLiked = result.dataOrNull ?? false;
            _profileService.likedStatusMap[contentId] = serverIsLiked;

            final updatedPost = _profileService.postsList.firstWhereOrNull(
              (p) => p.id == contentId,
            );
            if (updatedPost != null) {
              final postIndex = _profileService.postsList.indexOf(updatedPost);
              _profileService.postsList[postIndex] = updatedPost.copyWith(
                likesCount: serverIsLiked
                    ? updatedPost.likesCount + (newIsLiked ? 0 : 1)
                    : (updatedPost.likesCount > 0
                          ? updatedPost.likesCount - (newIsLiked ? 1 : 0)
                          : 0),
              );
            }

            await _profileService.refreshLikedByUsers(contentId);
          } else {
            _profileService.likedStatusMap[contentId] = previousIsLiked;
            if (index < _profileService.postsList.length) {
              _profileService.postsList[index] = post.copyWith(
                likesCount: previousLikesCount,
              );
            }
            _profileService.likedByUsersMap[contentId] = previousLikedByUsers;
            CommonSnackbar.error(
              result.errorOrNull ?? 'failed_to_like_post'.tr,
            );
          }
        })
        .catchError((error) {
          _profileService.likedStatusMap[contentId] = previousIsLiked;
          if (index < _profileService.postsList.length) {
            _profileService.postsList[index] = post.copyWith(
              likesCount: previousLikesCount,
            );
          }
          _profileService.likedByUsersMap[contentId] = previousLikedByUsers;
          CommonSnackbar.error('somethingWentWrong'.tr);
        });
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
      final post = _profileService.postsList.firstWhereOrNull(
        (p) => p.id == contentId,
      );
      if (post != null) {
        final index = _profileService.postsList.indexOf(post);
        _profileService.postsList[index] = post.copyWith(
          commentsCount: post.commentsCount + 1,
        );
      }
      CommonSnackbar.success('Comment added');
    } else {
      CommonSnackbar.error(result.errorOrNull ?? 'failed_to_add_comment'.tr);
    }
  }

  void showCommentsModal(String contentId) {
    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: CommentsModal(
        contentId: contentId,
        onAddComment: (String commentText) async {
          await loadUserPosts();
        },
      ),
    );
  }

  void showFeedActionModal(String? id) {
    if (id == null) return;

    final content = _profileService.postsList.firstWhereOrNull(
      (c) => c.id == id,
    );
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
                CommonSnackbar.success('shared_to_instagram'.tr);
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
                CommonSnackbar.success('shared_to_facebook'.tr);
              }
            },
            onTikTokTap: () async {
              if (Navigator.of(modalContext, rootNavigator: true).canPop()) {
                Navigator.of(modalContext, rootNavigator: true).pop();
              }
              if (contentId != null) {
                await _contentService.updateContent(
                  contentId,
                  externalSharePlatforms: ['TIKTOK'],
                );
                CommonSnackbar.success('shared_to_tiktok'.tr);
              }
            },
            onCommunityFeedTap: () async {
              if (Navigator.of(modalContext, rootNavigator: true).canPop()) {
                Navigator.of(modalContext, rootNavigator: true).pop();
              }
              if (contentId != null) {
                await _contentService.updateContent(
                  contentId,
                  externalSharePlatforms: ['COMMUNITY_FEED'],
                );
                CommonSnackbar.success('shared_to_community_feed'.tr);
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
        CommonSnackbar.success('post_deleted_successfully'.tr);
        Future.delayed(const Duration(seconds: 1), () {
          _profileService.loadUserPosts();
          _profileService.loadUserProfile();
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
      CommonSnackbar.error('failed_to_select_image'.tr);
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
      CommonSnackbar.error('user_not_found'.tr);
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
        CommonSnackbar.success('profile_picture_updated'.tr);
      } else {
        CommonSnackbar.error('failed_to_upload_profile_picture'.tr);
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      CommonSnackbar.error('failed_to_upload_profile_picture'.tr);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _updateUserProfilePicture(String imageUrl) async {
    try {
      final currentUser = _profileService.user.value;
      if (currentUser == null) return;

      await SupabaseService.client
          .from('users')
          .update({'profile_picture_url': imageUrl})
          .eq('id', currentUser.id);

      final updatedJson = currentUser.toJson();
      updatedJson['profile_picture_url'] = imageUrl;
      final updatedUserModel = UserModel.fromJson(updatedJson);
      _profileService.user.value = updatedUserModel;
      await _authRepo.loadCurrentUser();
      await _profileService.refreshProfileData();
    } catch (e) {
      debugPrint('Error updating user profile picture: $e');
      rethrow;
    }
  }
}
