import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/models/user_model copy.dart';

class BlockedUsersController extends BaseController {
  final RxList<UserModel> blockedUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredBlockedUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadBlockedUsers();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _filterUsers();
  }

  void _filterUsers() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredBlockedUsers.value = blockedUsers;
    } else {
      filteredBlockedUsers.value = blockedUsers.where((user) {
        final name = user.fullName?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    }
  }

  Future<void> loadBlockedUsers() async {
    try {
      setLoading(true);
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        handleError('user_not_found'.tr);
        return;
      }

      final response = await SupabaseService.client
          .from('user_blocks')
          .select('''
            blocked_id,
            users!user_blocks_blocked_id_fkey (
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
          .eq('blocker_id', currentUser.id)
          .isFilter('deleted_at', null);

      final List<UserModel> users = [];
      for (final item in response as List) {
        final userData = item['users'] as Map<String, dynamic>?;
        if (userData != null) {
          // Add required fields with defaults
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

      blockedUsers.value = users;
      filteredBlockedUsers.value = users;
    } catch (e) {
      debugPrint('Error loading blocked users: $e');
      handleError('failed_to_load_blocked_users'.tr);
    } finally {
      setLoading(false);
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return;
      }

      await SupabaseService.client
          .from('user_blocks')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('blocker_id', currentUser.id)
          .eq('blocked_id', userId);

      blockedUsers.removeWhere((user) => user.id == userId);
      filteredBlockedUsers.removeWhere((user) => user.id == userId);

      CommonSnackbar.success('user_unblocked_successfully'.tr);
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      CommonSnackbar.error('failed_to_unblock_user'.tr);
    }
  }
}
