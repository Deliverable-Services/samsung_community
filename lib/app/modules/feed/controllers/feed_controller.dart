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
import '../../../repository/auth_repo/auth_repo.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/social_media_modal.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/user_model copy.dart';
import '../local_widgets/feed_action_modal.dart';
import '../local_widgets/comments_modal.dart';

class FeedController extends BaseController {
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
  static const int maxCachedItems =
      50; // Limit cached items to prevent memory issues
  int _currentOffset = 0;
  bool _isDeleting = false;

  final selectedImagePath = Rxn<File>();
  final profilePictureUrl = Rxn<String>();
  final isUploadingImage = false.obs;
  bool _isOpeningSocialModal = false;

  FeedController({
    ContentService? contentService,
    ContentInteractionService? interactionService,
  }) : _contentService = contentService ?? ContentService(),
       _interactionService = interactionService ?? ContentInteractionService();

  final AuthRepo _authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    loadContent();

    debugPrint('Analytics: viewing the community feed screen');
  }

  @override
  void onReady() {
    super.onReady();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    await _authRepo.loadCurrentUser();
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
        .isFilter('deleted_at', null)
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
          SizedBox(
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
          if (contentList.length > maxCachedItems) {
            contentList.value = contentList.sublist(
              contentList.length - maxCachedItems,
            );
            _currentOffset = contentList.length;
          }
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
                title: Text(
                  'choose_from_gallery'.tr,
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: Text(
                  'take_photo'.tr,
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(color: AppColors.white),
                ),
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
        CommonSnackbar.error('failed_to_upload_profile_picture'.tr);
        selectedImagePath.value = null;
      }
    } catch (e) {
      CommonSnackbar.error('failed_to_upload_profile_picture'.tr);
      selectedImagePath.value = null;
    } finally {
      isUploadingImage.value = false;
    }
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
                CommonSnackbar.success('shared_to_instagram'.tr);
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
                CommonSnackbar.success('shared_to_facebook'.tr);
              }
            },
            onTikTokTap: () async {
              if (Navigator.of(modalContext, rootNavigator: true).canPop()) {
                Navigator.of(modalContext, rootNavigator: true).pop();
              }
              _isOpeningSocialModal = false;
              debugPrint('Sharing to TikTok...');
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
              _isOpeningSocialModal = false;
              debugPrint('Sharing to Community Feed...');
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
    ).then((_) {
      _isOpeningSocialModal = false;
    });
  }

  /// Show feed action modal (delete/share)
  void showFeedActionModal(String? id) {
    if (id == null) return;

    final content = contentList.firstWhereOrNull((c) => c.id == id);
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
          debugPrint('Delete post at index: $id');
          Get.back();
          deleteContent(id);
        },
        onShare: () {
          debugPrint('Analytics: user shared a post in the feed');
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
    if (_isDeleting) return;

    try {
      _isDeleting = true;
      final result = await _contentService.deleteContent(contentId);

      if (result.isSuccess) {
        CommonSnackbar.success('post_deleted_successfully'.tr);
        // Reload content after 1 second - loading will be handled by onInit
        Future.delayed(const Duration(seconds: 1), () {
          onInit();
        });
      } else {
        handleError(result.errorOrNull ?? 'failed_to_delete_post'.tr);
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      _isDeleting = false;
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
      CommonSnackbar.error('please_login_to_like_content'.tr);
      return;
    }

    final previousIsLiked = likedStatusMap[contentId] ?? false;
    final contentIndex = contentList.indexWhere((c) => c.id == contentId);
    if (contentIndex == -1) return;

    final content = contentList[contentIndex];
    final previousLikesCount = content.likesCount;
    final previousLikedByUsers = List<UserModel>.from(
      likedByUsersMap[contentId] ?? [],
    );

    final newIsLiked = !previousIsLiked;
    likedStatusMap[contentId] = newIsLiked;

    final newLikesCount = newIsLiked
        ? previousLikesCount + 1
        : (previousLikesCount > 0 ? previousLikesCount - 1 : 0);

    contentList[contentIndex] = content.copyWith(likesCount: newLikesCount);

    final filteredIndex = filteredContentList.indexWhere(
      (c) => c.id == contentId,
    );
    if (filteredIndex != -1) {
      filteredContentList[filteredIndex] = contentList[contentIndex];
    }

    if (newIsLiked) {
      final currentUser = _authRepo.currentUser.value;
      if (currentUser != null) {
        final existingLikedBy = likedByUsersMap[contentId] ?? [];
        final userExists = existingLikedBy.any((u) => u.id == currentUserId);
        if (!userExists) {
          final userJson = currentUser.toJson();
          final convertedUser = UserModel.fromJson(userJson);
          final updatedList = <UserModel>[convertedUser, ...existingLikedBy];
          likedByUsersMap[contentId] = updatedList.take(3).toList();
        }
      }
    } else {
      final existingLikedBy = likedByUsersMap[contentId] ?? [];
      likedByUsersMap[contentId] = existingLikedBy
          .where((u) => u.id != currentUserId)
          .toList();
    }

    _interactionService
        .toggleLike(contentId: contentId, userId: currentUserId)
        .then((result) async {
          if (result.isSuccess) {
            final serverIsLiked = result.dataOrNull ?? false;
            likedStatusMap[contentId] = serverIsLiked;

            if (contentIndex != -1 && contentIndex < contentList.length) {
              final currentContent = contentList[contentIndex];
              final serverLikesCount = serverIsLiked
                  ? previousLikesCount + (previousIsLiked ? 0 : 1)
                  : (previousLikesCount > 0 ? previousLikesCount - 1 : 0);

              contentList[contentIndex] = currentContent.copyWith(
                likesCount: serverLikesCount,
              );

              if (filteredIndex != -1 &&
                  filteredIndex < filteredContentList.length) {
                filteredContentList[filteredIndex] = contentList[contentIndex];
              }

              if (serverIsLiked) {
                await _loadLikedByUsers([contentList[contentIndex]]);
              } else {
                final existingLikedBy = likedByUsersMap[contentId] ?? [];
                likedByUsersMap[contentId] = existingLikedBy
                    .where((u) => u.id != currentUserId)
                    .toList();
              }
            }
          } else {
            likedStatusMap[contentId] = previousIsLiked;
            if (contentIndex != -1 && contentIndex < contentList.length) {
              contentList[contentIndex] = content.copyWith(
                likesCount: previousLikesCount,
              );
              if (filteredIndex != -1 &&
                  filteredIndex < filteredContentList.length) {
                filteredContentList[filteredIndex] = contentList[contentIndex];
              }
            }
            likedByUsersMap[contentId] = previousLikedByUsers;
            handleError(result.errorOrNull ?? 'failed_to_like_content'.tr);
          }
        })
        .catchError((error) {
          likedStatusMap[contentId] = previousIsLiked;
          if (contentIndex != -1 && contentIndex < contentList.length) {
            contentList[contentIndex] = content.copyWith(
              likesCount: previousLikesCount,
            );
            if (filteredIndex != -1 &&
                filteredIndex < filteredContentList.length) {
              filteredContentList[filteredIndex] = contentList[contentIndex];
            }
          }
          likedByUsersMap[contentId] = previousLikedByUsers;
          handleError('somethingWentWrong'.tr);
        });
  }

  Future<void> addComment(String contentId, String commentText) async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null) {
      CommonSnackbar.error('please_login_to_comment'.tr);
      return;
    }

    if (commentText.trim().isEmpty) {
      CommonSnackbar.error('comment_cannot_be_empty'.tr);
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

        CommonSnackbar.success('comment_added_successfully'.tr);
      } else {
        handleError(result.errorOrNull ?? 'failed_to_add_comment'.tr);
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
        onCommentsCountUpdated: (totalCount) {
          // Sync the commentsCount shown on the card with the actual total
          final contentIndex = contentList.indexWhere((c) => c.id == contentId);
          if (contentIndex != -1) {
            final content = contentList[contentIndex];
            contentList[contentIndex] = content.copyWith(
              commentsCount: totalCount,
            );

            final filteredIndex = filteredContentList.indexWhere(
              (c) => c.id == contentId,
            );
            if (filteredIndex != -1) {
              filteredContentList[filteredIndex] = contentList[contentIndex];
            }
          }
        },
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
    searchController.dispose();
    super.onClose();
  }
}
