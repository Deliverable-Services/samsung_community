import 'package:get/get.dart';

import '../../../common/services/content_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/user_model copy.dart';

class UserProfileController extends GetxController {
  final ContentService _contentService;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<ContentModel> postsList = <ContentModel>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFollowing = false.obs;
  final RxBool isFollowedBy = false.obs;
  final RxBool isLoadingFollow = false.obs;

  int postsCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  late final String targetUserId;

  UserProfileController({ContentService? contentService})
    : _contentService = contentService ?? ContentService();

  @override
  void onInit() {
    super.onInit();
    targetUserId = Get.parameters['userId'] ?? '';
    loadUserProfile();
    loadUserPosts();
    _loadFollowState();
  }

  Future<void> loadUserProfile() async {
    if (targetUserId.isEmpty) return;
    try {
      isLoading.value = true;
      final response = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('id', targetUserId)
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
        postsCount = allPosts.where((p) => p.userId == targetUserId).length;
  }

      final followersResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('following_id', targetUserId);
      followersCount = (followersResult as List).length;

      final followingResult = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', targetUserId);
      followingCount = (followingResult as List).length;
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

  Future<void> _loadFollowState() async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || targetUserId.isEmpty) return;
    final result = await SupabaseService.client
        .from('user_follows')
        .select()
        .eq('follower_id', currentUserId)
        .eq('following_id', targetUserId)
        .maybeSingle();
    isFollowing.value = result != null;

    final reverseResult = await SupabaseService.client
        .from('user_follows')
        .select()
        .eq('follower_id', targetUserId)
        .eq('following_id', currentUserId)
        .maybeSingle();
    isFollowedBy.value = reverseResult != null;
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
        followersCount = (followersCount - 1).clamp(0, 1 << 31).toInt();
      } else {
        await SupabaseService.client.from('user_follows').insert({
          'follower_id': currentUserId,
          'following_id': targetUserId,
        });
        isFollowing.value = true;
        followersCount += 1;
      }
    } catch (_) {
    } finally {
      isLoadingFollow.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar('error'.tr, message);
  }
}
