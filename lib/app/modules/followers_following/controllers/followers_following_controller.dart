import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/models/user_model copy.dart';
import '../../../routes/app_pages.dart';

class FollowersFollowingController extends BaseController {
  final RxInt selectedTab = 0.obs;
  final RxList<UserModel> followers = <UserModel>[].obs;
  final RxList<UserModel> following = <UserModel>[].obs;
  final RxList<UserModel> filteredFollowers = <UserModel>[].obs;
  final RxList<UserModel> filteredFollowing = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxMap<String, bool> isFollowingMap = <String, bool>{}.obs;
  final RxMap<String, bool> isFollowingBackMap = <String, bool>{}.obs;
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
        handleError('User not found');
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
      handleError('Failed to load data');
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
        await _checkFollowStatus(userId, user.id);
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
    } catch (e) {
      debugPrint('Error loading following: $e');
    }
  }

  Future<void> _checkFollowStatus(String currentUserId, String otherUserId) async {
    try {
      final response = await SupabaseService.client
          .from('user_follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', otherUserId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      isFollowingMap[otherUserId] = response != null;
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  bool isFollowing(String userId) {
    return isFollowingMap[userId] ?? false;
  }

  bool isFollowingBack(String userId) {
    return isFollowingBackMap[userId] ?? false;
  }

  Future<void> followUser(String userId) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('User not found');
        return;
      }

      await SupabaseService.client.from('user_follows').insert({
        'follower_id': currentUser.id,
        'following_id': userId,
      });

      isFollowingMap[userId] = true;
      CommonSnackbar.success('User followed');
      await loadData();
    } catch (e) {
      debugPrint('Error following user: $e');
      CommonSnackbar.error('Failed to follow user');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('User not found');
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
      CommonSnackbar.success('User unfollowed');
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      CommonSnackbar.error('Failed to unfollow user');
    }
  }

  Future<void> navigateToChat(String otherUserId) async {
    final currentUser = SupabaseService.currentUser;
    if (currentUser == null) {
      CommonSnackbar.error('User not found');
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
        CommonSnackbar.error('Failed to create conversation');
      }
    } catch (e) {
      CommonSnackbar.error('Failed to open chat');
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
}
