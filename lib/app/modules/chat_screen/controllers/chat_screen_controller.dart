import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../common/services/event_tracking_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../local_widgets/chat_options_modal.dart';
import '../local_widgets/report_success_modal.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isFromCurrentUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isFromCurrentUser,
  });
}

class ChatScreenController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  final Rx<UserModel?> otherUser = Rx<UserModel?>(null);
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString conversationId = ''.obs;
  final RxString currentUserId = ''.obs;
  final RxBool isBlocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    debugPrint('Analytics: viewing the message screen.');
    EventTrackingService.trackEvent(
      eventType: 'chat_screen_view',
      eventProperties: {
        'conversation_id': args != null ? args['conversationId'] : '',
        'target_user_id': args != null ? args['userId'] : '',
      },
    );
    if (args != null && args is Map) {
      conversationId.value = args['conversationId'] ?? '';
      final userId = args['userId'] as String?;
      if (userId != null) {
        loadUserData(userId);
      }
      _initializeChat();
    }
  }

  Future<void> _initializeChat() async {
    await _getCurrentUserId();
    if (conversationId.value.isNotEmpty) {
      await loadMessages();
      await markAsRead();
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final userData = await SupabaseService.client
            .from('users')
            .select('id')
            .eq('auth_user_id', user.id)
            .isFilter('deleted_at', null)
            .single();
        currentUserId.value = userData['id'] as String;
      }
    } catch (e) {
      print('Error getting current user ID: $e');
    }
  }

  Future<void> loadUserData(String userId) async {
    try {
      isLoading.value = true;
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .isFilter('deleted_at', null)
          .single();

      otherUser.value = UserModel.fromJson(response);
      await _checkBlockStatus(userId);
    } catch (e) {
      CommonSnackbar.error('failed_to_load_user_data'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkBlockStatus(String userId) async {
    try {
      if (currentUserId.value.isEmpty) {
        await _getCurrentUserId();
      }

      final response = await SupabaseService.client
          .from('user_blocks')
          .select()
          .eq('blocker_id', currentUserId.value)
          .eq('blocked_id', userId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      isBlocked.value = response != null;
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  Future<void> loadMessages() async {
    if (conversationId.value.isEmpty) return;
    if (currentUserId.value.isEmpty) {
      await _getCurrentUserId();
    }

    try {
      isLoading.value = true;
      final response = await SupabaseService.client
          .from('conversation_messages')
          .select(
            '*, sender:users!conversation_messages_sender_id_fkey(id, full_name, profile_picture_url)',
          )
          .eq('conversation_id', conversationId.value)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      messages.value = (response as List).map((msg) {
        final senderId = msg['sender_id'] as String;
        return ChatMessage(
          id: msg['id'] as String,
          senderId: senderId,
          content: msg['content'] as String? ?? '',
          createdAt: DateTime.parse(msg['created_at'] as String),
          isFromCurrentUser: senderId == currentUserId.value,
        );
      }).toList();
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || conversationId.value.isEmpty || isBlocked.value) return;

    try {
      isSending.value = true;
      await SupabaseService.client.from('conversation_messages').insert({
        'conversation_id': conversationId.value,
        'sender_id': currentUserId.value,
        'content': text,
      });

      messageController.clear();
      await loadMessages();
      markAsRead();
    } catch (e) {
      CommonSnackbar.error('failed_to_send_message'.tr);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> markAsRead() async {
    if (conversationId.value.isEmpty || currentUserId.value.isEmpty) {
      print(
        'Cannot mark as read: conversationId=${conversationId.value}, currentUserId=${currentUserId.value}',
      );
      return;
    }

    try {
      final now = DateTime.now().toIso8601String();
      print(
        'Marking messages as read: conversationId=${conversationId.value}, userId=${currentUserId.value}, time=$now',
      );

      final result = await SupabaseService.client
          .from('conversation_participants')
          .update({'last_read_at': now})
          .eq('conversation_id', conversationId.value)
          .eq('user_id', currentUserId.value)
          .select();

      print('Mark as read result: $result');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void navigateToProfile() {
    if (otherUser.value != null) {
      Get.toNamed('/user-profile', parameters: {'userId': otherUser.value!.id});
    }
  }

  void showChatOptionsModal() {
    final context = Get.context;
    if (context == null) return;
    ChatOptionsModal.show(context, this);
  }

  void showReportSuccessModal() {
    final context = Get.context;
    if (context == null) return;
    ReportSuccessModal.show(context);
  }

  Future<void> blockUser() async {
    if (otherUser.value == null || currentUserId.value.isEmpty) return;

    debugPrint('Blocking user: ${currentUserId.value} ${otherUser.value!.id}');

    try {
      await SupabaseService.client.from('user_blocks').upsert({
        'blocker_id': currentUserId.value,
        'blocked_id': otherUser.value!.id,
        // If a matching record already exists (same blocker & blocked),
        // ensure it is "re-activated" by clearing any soft-delete flag.
        'deleted_at': null,
      }, onConflict: 'blocker_id,blocked_id');

      await SupabaseService.client
          .from('user_follows')
          .delete()
          .or(
            'and(follower_id.eq.${currentUserId.value},following_id.eq.${otherUser.value!.id}),and(follower_id.eq.${otherUser.value!.id},following_id.eq.${currentUserId.value})',
          );

      isBlocked.value = true;
      CommonSnackbar.success('user_blocked_successfully'.tr);
    } catch (e) {
      debugPrint('Error blocking user: $e');
      CommonSnackbar.error('failed_to_block_user'.tr);
    }
  }

  Future<void> unblockUser() async {
    if (otherUser.value == null || currentUserId.value.isEmpty) return;

    try {
      await SupabaseService.client
          .from('user_blocks')
          .delete()
          .eq('blocker_id', currentUserId.value)
          .eq('blocked_id', otherUser.value!.id);

      isBlocked.value = false;
      CommonSnackbar.success('user_unblocked_successfully'.tr);
    } catch (e) {
      print('Error unblocking user: $e');
      CommonSnackbar.error('failed_to_unblock_user'.tr);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
