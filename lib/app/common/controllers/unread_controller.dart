import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/services/supabase_service.dart';

class UnreadController extends GetxController {
  final RxInt totalUnreadCount = 0.obs;
  RealtimeChannel? _messagesChannel;
  String? _currentUserId;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _getCurrentUserId();
    if (_currentUserId != null) {
      await fetchTotalUnreadCount();
      _setupRealtimeSubscription();
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        final userData = await SupabaseService.client
            .from('users')
            .select('id')
            .eq('auth_user_id', user.id)
            .single();
        _currentUserId = userData['id'] as String;
      }
    } catch (e) {
      print('UnreadController: Error getting current user ID: $e');
    }
  }

  Future<void> fetchTotalUnreadCount() async {
    if (_currentUserId == null) return;

    try {
      // 1. Get all conversations the user is a participant in
      final participantsResponse = await SupabaseService.client
          .from('conversation_participants')
          .select('conversation_id, last_read_at')
          .eq('user_id', _currentUserId!)
          .isFilter('deleted_at', null);

      final participants = participantsResponse as List;
      int totalCount = 0;

      for (final participant in participants) {
        final convId = participant['conversation_id'] as String;
        final lastReadAt = participant['last_read_at'] as String?;

        var query = SupabaseService.client
            .from('conversation_messages')
            .select('id')
            .eq('conversation_id', convId)
            .neq('sender_id', _currentUserId!)
            .isFilter('deleted_at', null);

        if (lastReadAt != null) {
          query = query.gt('created_at', lastReadAt);
        }

        final countResponse = await query.count(CountOption.exact);
        totalCount += countResponse.count;
      }

      totalUnreadCount.value = totalCount;
    } catch (e) {
      print('UnreadController: Error fetching total unread count: $e');
    }
  }

  void _setupRealtimeSubscription() {
    if (_currentUserId == null) return;

    _messagesChannel = SupabaseService.client
        .channel('public:unread_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversation_messages',
          callback: (payload) {
            fetchTotalUnreadCount();
          },
        )
        .subscribe();
  }

  @override
  void onClose() {
    if (_messagesChannel != null) {
      SupabaseService.client.removeChannel(_messagesChannel!);
    }
    super.onClose();
  }
}
