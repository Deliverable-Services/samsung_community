import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/models/user_model copy.dart';
import '../../../routes/app_pages.dart';
import '../../chat_screen/local_widgets/report_success_modal.dart';

class FollowersFollowingController extends BaseController {
  final RxInt selectedTab = 0.obs;
  final RxList<UserModel> followers = <UserModel>[].obs;
  final RxList<UserModel> following = <UserModel>[].obs;
  final RxList<UserModel> filteredFollowers = <UserModel>[].obs;
  final RxList<UserModel> filteredFollowing = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxMap<String, bool> isFollowingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isFollowedByMap = <String, bool>{}.obs;
  late final String targetUserId;

  @override
  void onInit() {
    super.onInit();
    final initialTab = Get.parameters['tab'];
    if (initialTab == 'following') {
      selectedTab.value = 1;
    }
    final paramUserId = Get.parameters['userId'];
    final currentUser = SupabaseService.currentUser;
    if (paramUserId != null && paramUserId.isNotEmpty) {
      targetUserId = paramUserId;
    } else {
      if (currentUser == null) {
        handleError('user_not_found'.tr);
        return;
      }
      targetUserId = currentUser.id;
    }
    loadData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    _filterUsers();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _filterUsers();
  }

  void _filterUsers() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredFollowers.value = followers;
      filteredFollowing.value = following;
    } else {
      filteredFollowers.value = followers.where((user) {
        final name = user.fullName?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
      filteredFollowing.value = following.where((user) {
        final name = user.fullName?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    }
  }

  Future<void> loadData() async {
    try {
      setLoading(true);
      await Future.wait([
        loadFollowers(targetUserId),
        loadFollowing(targetUserId),
      ]);
    } catch (e) {
      debugPrint('Error loading followers/following: $e');
      handleError('failed_to_load_data'.tr);
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadFollowers(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('user_follows')
          .select('''
            follower_id,
            users!user_follows_follower_id_fkey (
              id,
              phone_number,
              full_name,
              profile_picture_url,
              language_preference,
              social_media_links,
              points_balance,
              status,
              role,
              is_online,
              created_at,
              updated_at
            )
          ''')
          .eq('following_id', userId)
          .isFilter('deleted_at', null);

      final List<UserModel> users = [];
      for (final item in response as List) {
        final userData = item['users'] as Map<String, dynamic>?;
        if (userData != null) {
          userData['language_preference'] ??= 'en';
          userData['social_media_links'] ??= {};
          userData['points_balance'] ??= 0;
          userData['status'] ??= 'pending';
          userData['role'] ??= 'user';
          userData['is_online'] ??= false;
          userData['created_at'] ??= DateTime.now().toIso8601String();
          userData['updated_at'] ??= DateTime.now().toIso8601String();

          final user = UserModel.fromJson(userData);
          users.add(user);
        }
      }

      followers.value = users;
      filteredFollowers.value = users;

      for (final user in users) {
        await _checkFollowStatuses(user.id);
      }
    } catch (e) {
      debugPrint('Error loading followers: $e');
    }
  }

  Future<void> loadFollowing(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('user_follows')
          .select('''
            following_id,
            users!user_follows_following_id_fkey (
              id,
              phone_number,
              full_name,
              profile_picture_url,
              language_preference,
              social_media_links,
              points_balance,
              status,
              role,
              is_online,
              created_at,
              updated_at
            )
          ''')
          .eq('follower_id', userId)
          .isFilter('deleted_at', null);

      final List<UserModel> users = [];
      for (final item in response as List) {
        final userData = item['users'] as Map<String, dynamic>?;
        if (userData != null) {
          userData['language_preference'] ??= 'en';
          userData['social_media_links'] ??= {};
          userData['points_balance'] ??= 0;
          userData['status'] ??= 'pending';
          userData['role'] ??= 'user';
          userData['is_online'] ??= false;
          userData['created_at'] ??= DateTime.now().toIso8601String();
          userData['updated_at'] ??= DateTime.now().toIso8601String();

          users.add(UserModel.fromJson(userData));
        }
      }

      following.value = users;
      filteredFollowing.value = users;

      for (final user in users) {
        await _checkFollowStatuses(user.id);
      }
    } catch (e) {
      debugPrint('Error loading following: $e');
    }
  }

  Future<void> _checkFollowStatuses(String otherUserId) async {
    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null || currentUserId == otherUserId) return;

    try {
      // Check if I follow them
      final followingResponse = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', otherUserId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      isFollowingMap[otherUserId] = followingResponse != null;

      // Check if they follow me
      final followedByResponse = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', otherUserId)
          .eq('following_id', currentUserId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      isFollowedByMap[otherUserId] = followedByResponse != null;
    } catch (e) {
      debugPrint('Error checking follow status for $otherUserId: $e');
    }
  }

  bool isFollowing(String userId) {
    return isFollowingMap[userId] ?? false;
  }

  bool isFollowedBy(String userId) {
    return isFollowedByMap[userId] ?? false;
  }

  Future<void> followUser(String userId) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return;
      }

      await SupabaseService.client.from('user_follows').insert({
        'follower_id': currentUser.id,
        'following_id': userId,
      });

      isFollowingMap[userId] = true;
      CommonSnackbar.success('user_followed'.tr);
      await loadData();
    } catch (e) {
      debugPrint('Error following user: $e');
      CommonSnackbar.error('failed_to_follow_user'.tr);
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return;
      }

      await SupabaseService.client
          .from('user_follows')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('follower_id', currentUser.id)
          .eq('following_id', userId);

      isFollowingMap[userId] = false;
      following.removeWhere((user) => user.id == userId);
      filteredFollowing.removeWhere((user) => user.id == userId);
      CommonSnackbar.success('user_unfollowed'.tr);
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      CommonSnackbar.error('failed_to_unfollow_user'.tr);
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return;
      }

      final now = DateTime.now().toUtc().toIso8601String();

      // 1. Create or Reactivate block record
      await SupabaseService.client.from('user_blocks').upsert({
        'blocker_id': currentUser.id,
        'blocked_id': userId,
        'deleted_at': null,
      }, onConflict: 'blocker_id,blocked_id');

      // 2. Remove any follow relationships in both directions
      await SupabaseService.client
          .from('user_follows')
          .update({'deleted_at': now})
          .or('and(follower_id.eq.${currentUser.id},following_id.eq.$userId),and(follower_id.eq.$userId,following_id.eq.${currentUser.id})');

      // Remove from followers/following lists locally
      followers.removeWhere((u) => u.id == userId);
      following.removeWhere((u) => u.id == userId);
      _filterUsers();

      CommonSnackbar.success('user_blocked_successfully'.tr);
    } catch (e) {
      debugPrint('Error blocking user: $e');
      CommonSnackbar.error('failed_to_block_user'.tr);
    }
  }

  Future<void> navigateToChat(String otherUserId) async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) {
      CommonSnackbar.error('user_not_found'.tr);
      return;
    }

    try {
      String? conversationId = await _findOrCreateConversation(
        currentUser.id,
        otherUserId,
      );

      if (conversationId != null) {
        Get.toNamed(
          Routes.CHAT_SCREEN,
          arguments: {
            'conversationId': conversationId,
            'userId': otherUserId,
          },
        );
      } else {
        CommonSnackbar.error('failed_to_create_conversation'.tr);
      }
    } catch (e) {
      CommonSnackbar.error('failed_to_open_chat'.tr);
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
      debugPrint('Error finding/creating conversation: $e');
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
          .insert({})
          .select('id')
          .single();

      final conversationId = newConversation['id'] as String;

      await SupabaseService.client.from('conversation_participants').insert([
        {'conversation_id': conversationId, 'user_id': currentUserId},
        {'conversation_id': conversationId, 'user_id': otherUserId},
      ]);

      return conversationId;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  void showReportSuccessModal() {
    final context = Get.context;
    if (context == null) return;
    ReportSuccessModal.show(context);
  }
}
