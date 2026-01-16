import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/content_service.dart';
import '../../../common/services/content_interaction_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/user_model copy.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../routes/app_pages.dart';
import '../../feed/local_widgets/comments_modal.dart';
import '../../feed/local_widgets/feed_action_modal.dart';
import '../../../data/helper_widgets/social_media_modal.dart';

class UserProfileController extends GetxController {
  final ContentService _contentService;
  final ContentInteractionService _interactionService;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<ContentModel> postsList = <ContentModel>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFollowing = false.obs;
  final RxBool isFollowedBy = false.obs;
  final RxBool isLoadingFollow = false.obs;
  final RxBool isBlocked = false.obs;

  final RxMap<String, bool> likedStatusMap = <String, bool>{}.obs;
  final RxMap<String, List<UserModel>> likedByUsersMap =
      <String, List<UserModel>>{}.obs;

  final RxInt postsCount = 0.obs;
  final RxInt followersCount = 0.obs;
  final RxInt followingCount = 0.obs;
  late final String targetUserId;

  UserProfileController({
    ContentService? contentService,
    ContentInteractionService? interactionService,
  }) : _contentService = contentService ?? ContentService(),
       _interactionService = interactionService ?? ContentInteractionService();

  @override
  void onInit() {
    super.onInit();
    targetUserId = Get.parameters['userId'] ?? '';
    if (targetUserId.isEmpty) {
      final args = Get.arguments;
      if (args != null && args is Map && args['userId'] != null) {
        targetUserId = args['userId'] as String;
      }
    }
    if (targetUserId.isNotEmpty) {
      loadUserProfile();
      loadUserPosts();
      _loadFollowState();
      _loadBlockState();
    }
  }

  Future<void> loadUserProfile() async {
    if (targetUserId.isEmpty) return;
    try {
      isLoading.value = true;
      final response = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('id', targetUserId)
          .isFilter('deleted_at', null)
          .maybeSingle();
      if (response != null) {
        user.value = UserModel.fromJson(response);
        await _loadUserStats();
      }
    } catch (e) {
      _showError('somethingWentWrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserStats() async {
    isLoadingStats.value = true;
    try {
      if (targetUserId.isEmpty) return;

      final postsResult = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );
      if (postsResult.isSuccess) {
        final allPosts = postsResult.dataOrNull ?? [];
        postsCount.value = allPosts
            .where((p) => p.userId == targetUserId)
            .length;
      }

      final followersResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('following_id', targetUserId)
          .isFilter('deleted_at', null);
      followersCount.value = (followersResult as List).length;

      final followingResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', targetUserId)
          .isFilter('deleted_at', null);
      followingCount.value = (followingResult as List).length;
    } catch (_) {
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadUserPosts() async {
    isLoadingPosts.value = true;
    isLoading.value = true;
    try {
      if (targetUserId.isEmpty) return;
      final result = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );
      if (result.isSuccess) {
        final allContent = result.dataOrNull ?? [];
        final userPosts = allContent
            .where((c) => c.userId == targetUserId)
            .toList();

        final targetUser = user.value;
        final updatedList = targetUser == null
            ? userPosts
            : userPosts
                  .map((content) => content.copyWith(userModel: targetUser))
                  .toList();

        postsList.value = updatedList;

        final currentUserId = SupabaseService.currentUser?.id;
        if (currentUserId != null) {
          await _loadLikedStatuses(updatedList, currentUserId);
          await _loadLikedByUsers(updatedList);
        }
      } else {
        _showError(result.errorOrNull ?? 'somethingWentWrong'.tr);
      }
    } catch (_) {
      _showError('somethingWentWrong'.tr);
    } finally {
      isLoadingPosts.value = false;
      isLoading.value = false;
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

  Future<void> _loadFollowState() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) return;
    final result = await SupabaseService.client
        .from('user_follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', targetUserId)
        .isFilter('deleted_at', null)
        .maybeSingle();
    isFollowing.value = result != null;

    final reverseResult = await SupabaseService.client
        .from('user_follows')
        .select()
        .eq('follower_id', targetUserId)
        .eq('following_id', currentUserId)
        .isFilter('deleted_at', null)
        .maybeSingle();
    isFollowedBy.value = reverseResult != null;
  }

  Future<void> _loadBlockState() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) return;

    final result = await SupabaseService.client
        .from('user_blocks')
        .select()
        .eq('blocker_id', currentUserId)
        .eq('blocked_id', targetUserId)
        .isFilter('deleted_at', null)
        .maybeSingle();
    isBlocked.value = result != null;
  }

  Future<void> followOrUnfollow() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) return;
    isLoadingFollow.value = true;
    try {
      if (isFollowing.value) {
        await SupabaseService.client
            .from('user_follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', targetUserId);
        isFollowing.value = false;
        followersCount.value = (followersCount.value - 1)
            .clamp(0, 1 << 31)
            .toInt();
      } else {
        await SupabaseService.client.from('user_follows').insert({
          'follower_id': currentUserId,
          'following_id': targetUserId,
        });
        isFollowing.value = true;
        followersCount.value += 1;
      }
    } catch (_) {
    } finally {
      isLoadingFollow.value = false;
    }
  }

  Future<void> blockUser() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) return;

    try {
      final now = DateTime.now().toUtc().toIso8601String();

      // 1. Create or Reactivate block record
      await SupabaseService.client.from('user_blocks').upsert({
        'blocker_id': currentUserId,
        'blocked_id': targetUserId,
        'deleted_at': null,
      }, onConflict: 'blocker_id,blocked_id');

      // 2. Remove any follow relationships in both directions
      await SupabaseService.client
          .from('user_follows')
          .delete()
          .or(
            'and(follower_id.eq.$currentUserId,following_id.eq.$targetUserId),and(follower_id.eq.$targetUserId,following_id.eq.$currentUserId)',
          );

      isBlocked.value = true;
      isFollowing.value = false;
      isFollowedBy.value = false;

      CommonSnackbar.success('user_blocked_successfully'.tr);
      Get.back(); // Go back from profile
    } catch (e) {
      debugPrint('Error blocking user: $e');
      CommonSnackbar.error('failed_to_block_user'.tr);
    }
  }

  Future<void> unblockUser() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) return;

    try {
      await SupabaseService.client
          .from('user_blocks')
          .delete()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', targetUserId);

      isBlocked.value = false;
      CommonSnackbar.success('user_unblocked_successfully'.tr);
      Get.back();
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      CommonSnackbar.error('failed_to_unblock_user'.tr);
    }
  }

  Future<void> toggleLike(String contentId) async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null) {
      CommonSnackbar.error('please_login_to_like_content'.tr);
      return;
    }

    final post = postsList.firstWhereOrNull((p) => p.id == contentId);
    if (post == null) return;

    // Store previous state for potential revert
    final previousIsLiked = likedStatusMap[contentId] ?? false;
    final previousLikesCount = post.likesCount;
    final previousLikedByUsers = List<UserModel>.from(
      likedByUsersMap[contentId] ?? [],
    );

    // Optimistic update - update UI immediately
    final newIsLiked = !previousIsLiked;
    likedStatusMap[contentId] = newIsLiked;

    final index = postsList.indexOf(post);
    final newLikesCount = newIsLiked
        ? previousLikesCount + 1
        : (previousLikesCount > 0 ? previousLikesCount - 1 : 0);

    postsList[index] = post.copyWith(likesCount: newLikesCount);

    // Update likedByUsers optimistically
    if (newIsLiked) {
      final existingLikedBy = likedByUsersMap[contentId] ?? [];
      final userExists = existingLikedBy.any((u) => u.id == currentUserId);
      if (!userExists) {
        // Get current user data from database to create UserModel
        SupabaseService.client
            .from('users')
            .select()
            .eq('id', currentUserId)
            .isFilter('deleted_at', null)
            .maybeSingle()
            .then((userResponse) {
              if (userResponse != null) {
                final convertedUser = UserModel.fromJson(userResponse);
                final updatedList = <UserModel>[
                  convertedUser,
                  ...existingLikedBy,
                ];
                likedByUsersMap[contentId] = updatedList.take(3).toList();
              }
            })
            .catchError((e) {
              debugPrint('Error getting current user for likedBy: $e');
            });
      }
    } else {
      final existingLikedBy = likedByUsersMap[contentId] ?? [];
      likedByUsersMap[contentId] = existingLikedBy
          .where((u) => u.id != currentUserId)
          .toList();
    }

    // Run API call in background
    _interactionService
        .toggleLike(contentId: contentId, userId: currentUserId)
        .then((result) async {
          if (result.isSuccess) {
            final serverIsLiked = result.dataOrNull ?? false;
            likedStatusMap[contentId] = serverIsLiked;

            final updatedPost = postsList.firstWhereOrNull(
              (p) => p.id == contentId,
            );
            if (updatedPost != null) {
              final postIndex = postsList.indexOf(updatedPost);
              postsList[postIndex] = updatedPost.copyWith(
                likesCount: serverIsLiked
                    ? updatedPost.likesCount + (newIsLiked ? 0 : 1)
                    : (updatedPost.likesCount > 0
                          ? updatedPost.likesCount - (newIsLiked ? 1 : 0)
                          : 0),
              );

              if (serverIsLiked) {
                await _loadLikedByUsers([postsList[postIndex]]);
              } else {
                final existingLikedBy = likedByUsersMap[contentId] ?? [];
                likedByUsersMap[contentId] = existingLikedBy
                    .where((u) => u.id != currentUserId)
                    .toList();
              }
            }
          } else {
            // Revert on error
            likedStatusMap[contentId] = previousIsLiked;
            if (index < postsList.length) {
              postsList[index] = post.copyWith(likesCount: previousLikesCount);
            }
            likedByUsersMap[contentId] = previousLikedByUsers;
            _showError(result.errorOrNull ?? 'failed_to_like_content'.tr);
          }
        })
        .catchError((error) {
          // Revert on exception
          likedStatusMap[contentId] = previousIsLiked;
          if (index < postsList.length) {
            postsList[index] = post.copyWith(likesCount: previousLikesCount);
          }
          likedByUsersMap[contentId] = previousLikedByUsers;
          _showError('somethingWentWrong'.tr);
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
        final post = postsList.firstWhereOrNull((p) => p.id == contentId);
        if (post != null) {
          final index = postsList.indexOf(post);
          postsList[index] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }

        CommonSnackbar.success('comment_added_successfully'.tr);
      } else {
        _showError(result.errorOrNull ?? 'failed_to_add_comment'.tr);
      }
    } catch (_) {
      _showError('somethingWentWrong'.tr);
    }
  }

  void showCommentsModal(String contentId) {
    if (Get.context == null) return;

    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: CommentsModal(
        contentId: contentId,
        onAddComment: (commentText) => addComment(contentId, commentText),
      ),
    );
  }

  void showFeedActionModal(String? id) {
    if (id == null || Get.context == null) return;

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
        onDelete: isOwnPost
            ? () {
                Get.back();
              }
            : null,
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

  Future<void> navigateToChat() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) {
      _showError('user_not_found'.tr);
      return;
    }

    try {
      String? conversationId = await _findOrCreateConversation(
        currentUserId,
        targetUserId,
      );

      if (conversationId != null) {
        Get.toNamed(
          Routes.CHAT_SCREEN,
          arguments: {'conversationId': conversationId, 'userId': targetUserId},
        );
      } else {
        _showError('failed_to_create_conversation'.tr);
      }
    } catch (e) {
      _showError('failed_to_open_chat'.tr);
    }
  }

  Future<String?> _findOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final currentUserConvs = await SupabaseService.client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null);

      if ((currentUserConvs as List).isEmpty) {
        return await _createNewConversation(currentUserId, otherUserId);
      }

      final convIds = (currentUserConvs as List)
          .map((c) => c['conversation_id'] as String)
          .toList();

      final sharedConversation = await SupabaseService.client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', otherUserId)
          .inFilter('conversation_id', convIds)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (sharedConversation != null) {
        return sharedConversation['conversation_id'] as String?;
      }

      return await _createNewConversation(currentUserId, otherUserId);
    } catch (e) {
      print('Error finding/creating conversation: $e');
      return null;
    }
  }

  Future<String?> _createNewConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final newConversation = await SupabaseService.client
          .from('conversations')
          .insert({'created_by': currentUserId})
          .select('id')
          .single();

      final conversationId = newConversation['id'] as String;

      await SupabaseService.client.from('conversation_participants').insert([
        {'conversation_id': conversationId, 'user_id': currentUserId},
        {'conversation_id': conversationId, 'user_id': otherUserId},
      ]);

      return conversationId;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  void _showError(String message) {
    Get.snackbar('error'.tr, message);
  }
}
