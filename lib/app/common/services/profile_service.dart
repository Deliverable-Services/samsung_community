import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/core/utils/result.dart';
import '../../data/models/content_model.dart';
import '../../data/models/user_model copy.dart';
import '../../repository/auth_repo/auth_repo.dart';
import 'content_interaction_service.dart';
import 'content_service.dart';
import 'supabase_service.dart';

class ProfileService extends GetxService {
  static ProfileService get instance => Get.find<ProfileService>();

  final AuthRepo _authRepo = Get.find<AuthRepo>();
  final ContentService _contentService = ContentService();
  final ContentInteractionService _interactionService = ContentInteractionService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<ContentModel> postsList = <ContentModel>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isLoadingStats = false.obs;

  final RxInt postsCount = 0.obs;
  final RxInt followersCount = 0.obs;
  final RxInt followingCount = 0.obs;

  final RxMap<String, bool> likedStatusMap = <String, bool>{}.obs;
  final RxMap<String, List<UserModel>> likedByUsersMap =
      <String, List<UserModel>>{}.obs;

  DateTime? _lastRefreshTime;

  @override
  void onInit() {
    super.onInit();
    _loadFromAuthRepo();
    _setupAuthRepoListener();
  }

  void _loadFromAuthRepo() {
    final currentUser = _authRepo.currentUser.value;
    if (currentUser != null) {
      final userJson = currentUser.toJson();
      user.value = UserModel.fromJson(userJson);
    }
  }

  void _setupAuthRepoListener() {
    _authRepo.currentUser.listen((updatedUser) {
      if (updatedUser != null) {
        final userJson = updatedUser.toJson();
        user.value = UserModel.fromJson(userJson);
      }
    });
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

  Future<void> loadUserProfile() async {
    try {
      final currentUser = _authRepo.currentUser.value;
      if (currentUser != null) {
        final userJson = currentUser.toJson();
        user.value = UserModel.fromJson(userJson);
        await _loadUserStats();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _loadUserStats() async {
    isLoadingStats.value = true;
    try {
      final currentUserId = _authRepo.currentUser.value?.id;
      if (currentUserId == null) return;

      final postsResult = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );
      if (postsResult.isSuccess) {
        final allPosts = postsResult.dataOrNull ?? [];
        postsCount.value = allPosts.where((p) => p.userId == currentUserId).length;
      }

      final followersResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('following_id', currentUserId)
          .isFilter('deleted_at', null);
      followersCount.value = (followersResult as List).length;

      final followingResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', currentUserId)
          .isFilter('deleted_at', null);
      followingCount.value = (followingResult as List).length;
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadUserPosts() async {
    isLoadingPosts.value = true;
    try {
      final currentUserId = _authRepo.currentUser.value?.id;
      if (currentUserId == null) {
        postsList.clear();
        return;
      }

      final result = await _contentService.getContent(
        contentType: ContentType.feed,
        isPublished: true,
      );

      if (result.isSuccess) {
        final allContent = result.dataOrNull ?? [];
        final userPosts = allContent.where((c) => c.userId == currentUserId).toList();

        final currentUser = _authRepo.currentUser.value;
        List<ContentModel> updatedList;
        if (currentUser != null) {
          final userJson = currentUser.toJson();
          final userModelCopy = UserModel.fromJson(userJson);
          updatedList = userPosts
              .map((content) => content.copyWith(userModel: userModelCopy))
              .toList();
        } else {
          updatedList = userPosts;
        }

        postsList.value = updatedList;

        if (currentUserId.isNotEmpty) {
          await _loadLikedStatuses(updatedList, currentUserId);
          await _loadLikedByUsers(updatedList);
        }
      } else {
        postsList.clear();
      }
    } catch (e) {
      debugPrint('Error loading user posts: $e');
      postsList.clear();
    } finally {
      isLoadingPosts.value = false;
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

  Future<void> refreshLikedByUsers(String contentId) async {
    final post = postsList.firstWhereOrNull((p) => p.id == contentId);
    if (post != null) {
      await _loadLikedByUsers([post]);
    }
  }
}

