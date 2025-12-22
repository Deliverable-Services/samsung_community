import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';

class ConversationItem {
  final String conversationId;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ConversationItem({
    required this.conversationId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });
}

class MessagesController extends GetxController {
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxList<ConversationItem> conversations = <ConversationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _getCurrentUserId();
    loadConversations();
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

  Future<void> loadConversations() async {
    if (currentUserId.value.isEmpty) {
      await _getCurrentUserId();
    }
    if (currentUserId.value.isEmpty) return;

    try {
      isLoading.value = true;
      
      final participantsResponse = await SupabaseService.client
          .from('conversation_participants')
          .select('conversation_id, last_read_at, conversations!inner(id, last_message_at)')
          .eq('user_id', currentUserId.value);

      final participants = participantsResponse as List;
      
      if (participants.isEmpty) {
        conversations.value = [];
        return;
      }

      final List<ConversationItem> loadedConversations = [];

      final sortedParticipants = participants.toList()
        ..sort((a, b) {
          final convA = a['conversations'] as Map<String, dynamic>?;
          final convB = b['conversations'] as Map<String, dynamic>?;
          final dateA = convA?['last_message_at'] as String?;
          final dateB = convB?['last_message_at'] as String?;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });

      for (final participant in sortedParticipants) {
        final conv = participant['conversations'] as Map<String, dynamic>?;
        if (conv == null) continue;
        final convId = conv['id'] as String;
        
        final otherParticipant = await SupabaseService.client
            .from('conversation_participants')
            .select('user_id')
            .eq('conversation_id', convId)
            .neq('user_id', currentUserId.value)
            .maybeSingle();

        String? otherUserId;
        String? otherUserName;
        String? otherUserAvatar;
        String? lastMessage;
        int unreadCount = 0;

        if (otherParticipant != null) {
          otherUserId = otherParticipant['user_id'] as String?;
          
          if (otherUserId != null) {
            final userData = await SupabaseService.client
                .from('users')
                .select('id, full_name, profile_picture_url')
                .eq('id', otherUserId)
                .maybeSingle();
            
            if (userData != null) {
              otherUserName = userData['full_name'] as String?;
              otherUserAvatar = userData['profile_picture_url'] as String?;
            }
          }
        }

        final lastMsgResponse = await SupabaseService.client
            .from('conversation_messages')
            .select('content, created_at')
            .eq('conversation_id', convId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastMsgResponse != null) {
          lastMessage = lastMsgResponse['content'] as String?;
        }

        final lastReadAt = participant['last_read_at'] as String?;
        if (lastReadAt != null) {
          final unreadResponse = await SupabaseService.client
              .from('conversation_messages')
              .select('id')
              .eq('conversation_id', convId)
              .gt('created_at', lastReadAt)
              .neq('sender_id', currentUserId.value);
          unreadCount = (unreadResponse as List).length;
        } else {
          final unreadResponse = await SupabaseService.client
              .from('conversation_messages')
              .select('id')
              .eq('conversation_id', convId)
              .neq('sender_id', currentUserId.value);
          unreadCount = (unreadResponse as List).length;
        }

        loadedConversations.add(ConversationItem(
          conversationId: convId,
          otherUserId: otherUserId,
          otherUserName: otherUserName ?? 'user'.tr,
          otherUserAvatar: otherUserAvatar,
          lastMessage: lastMessage,
          lastMessageAt: conv['last_message_at'] != null
              ? DateTime.parse(conv['last_message_at'] as String)
              : null,
          unreadCount: unreadCount,
        ));
      }

      conversations.value = loadedConversations;
    } catch (e) {
      print('Error loading conversations: $e');
      conversations.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  List<ConversationItem> get filteredConversations {
    if (searchQuery.value.isEmpty) {
      return conversations;
    }
    return conversations.where((conv) {
      final name = conv.otherUserName?.toLowerCase() ?? '';
      final message = conv.lastMessage?.toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return name.contains(query) || message.contains(query);
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
