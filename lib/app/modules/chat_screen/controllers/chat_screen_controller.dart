import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../common/services/supabase_service.dart';

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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      conversationId.value = args['conversationId'] ?? '';
      final userId = args['userId'] as String?;
      if (userId != null) {
        loadUserData(userId);
      }
      if (conversationId.value.isNotEmpty) {
        loadMessages();
      }
    }
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final user = await SupabaseService.client.auth.currentUser;
      if (user != null) {
        final userData = await SupabaseService.client
            .from('users')
            .select('id')
            .eq('auth_user_id', user.id)
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
          .single();
      
      otherUser.value = UserModel.fromJson(response);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages() async {
    if (conversationId.value.isEmpty) return;
    
    try {
      isLoading.value = true;
      final response = await SupabaseService.client
          .from('conversation_messages')
          .select('*, sender:users!conversation_messages_sender_id_fkey(id, full_name, profile_picture_url)')
          .eq('conversation_id', conversationId.value)
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
    if (text.isEmpty || conversationId.value.isEmpty) return;

    try {
      isSending.value = true;
      await SupabaseService.client
          .from('conversation_messages')
          .insert({
            'conversation_id': conversationId.value,
            'sender_id': currentUserId.value,
            'content': text,
          });
      
      messageController.clear();
      await loadMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSending.value = false;
    }
  }

  void navigateToProfile() {
    if (otherUser.value != null) {
      Get.toNamed('/user-profile', arguments: {'userId': otherUser.value!.id});
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
