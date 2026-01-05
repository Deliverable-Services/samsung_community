import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';
import '../repo/notifications_model.dart';

class NotificationsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxString currentUserId = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _getCurrentUserId();
    searchController.addListener(_onSearchChanged);
    loadNotifications();
  }

  @override
  void onReady() {
    loadNotifications();
  }

  bool get hasUnreadNotifications {
    return notifications.any((n) => !n.isRead);
  }


  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  List<NotificationItem> get filteredNotifications {
    if (searchQuery.value.isEmpty) {
      return notifications;
    }

    final query = searchQuery.value.toLowerCase();

    return notifications.where((n) {
      return n.title.toLowerCase().contains(query) ||
          n.message.toLowerCase().contains(query) ||
          n.notificationType.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _getCurrentUserId() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      currentUserId.value = user.id ?? '';
    }
  }

  Future<void> loadNotifications() async {
    if (currentUserId.value.isEmpty) return;

    try {
      isLoading.value = true;

      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', currentUserId.value)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      notifications.value = (response as List).map((e) {
        return NotificationItem(
          id: e['id'],
          title: e['title'],
          message: e['message'],
          isRead: e['is_read'],
          notificationType: e['notification_type'],
          createdAt: DateTime.parse(e['created_at']),
          relatedEntityType: e['related_entity_type'],
          relatedEntityId: e['related_entity_id'],
        );
      }).toList();
    } catch (e) {
      print('Notification error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    await SupabaseService.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);

    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = NotificationItem(
        id: notifications[index].id,
        title: notifications[index].title,
        message: notifications[index].message,
        isRead: true,
        notificationType: notifications[index].notificationType,
        createdAt: notifications[index].createdAt,
        relatedEntityType: notifications[index].relatedEntityType,
        relatedEntityId: notifications[index].relatedEntityId,
      );
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
