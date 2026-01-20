import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../routes/app_pages.dart';
import '../../bottom_bar/controllers/bottom_bar_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../repo/notifications_model.dart';

class NotificationsController extends BaseController {
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxString currentUserId = ''.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _pollingTimer;

  static const int pageSize = 15;
  int currentOffset = 0;

  @override
  void onInit() {
    super.onInit();
    _getCurrentUserId().then((_) {
      loadNotifications();
      _startPollingNotifications();
    });
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_scrollListener);
  }

  void _startPollingNotifications() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentUserId.value.isNotEmpty &&
          !isLoading.value &&
          searchQuery.value.isEmpty) {
        fetchLatestNotifications();
      }
    });
  }

  Future<void> fetchLatestNotifications() async {
    if (notifications.isEmpty) return;

    final latestTimestamp = notifications.first.createdAt.toIso8601String();

    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', currentUserId.value)
          .isFilter('deleted_at', null)
          .gt('created_at', latestTimestamp)
          .order('created_at', ascending: false);
      debugPrint('response:123 $response');

      final latestItems = (response as List)
          .map((e) => NotificationItem.fromJson(e))
          .toList();

      if (latestItems.isNotEmpty) {
        notifications.insertAll(0, latestItems);
        currentOffset += latestItems.length;
        // Mark these new items as read since they are now on screen
        // _markUnreadAsReadInDB(latestItems);
      }
    } catch (e) {
      debugPrint('Error polling notifications: $e');
    }
  }

  bool get hasUnreadNotifications {
    return notifications.any((n) => !n.isRead);
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMoreData.value &&
        searchQuery.value.isEmpty) {
      loadMoreNotifications();
    }
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
    _pollingTimer?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _getCurrentUserId() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      currentUserId.value = user.id;
    }
  }

  Future<void> loadNotifications() async {
    if (currentUserId.value.isEmpty) {
      await _getCurrentUserId();
    }
    if (currentUserId.value.isEmpty) return;

    try {
      setLoading(true);
      currentOffset = 0;
      hasMoreData.value = true;

      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', currentUserId.value)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .range(0, pageSize - 1);
      debugPrint('response:456 $response');

      final newItems = (response as List)
          .map((e) => NotificationItem.fromJson(e))
          .toList();
      notifications.assignAll(newItems);
      hasMoreData.value = newItems.length == pageSize;
      currentOffset = newItems.length;

      // Don't auto-mark as read - let user control this
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value ||
        !hasMoreData.value ||
        currentUserId.value.isEmpty)
      return;

    try {
      isLoadingMore.value = true;

      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', currentUserId.value)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .range(currentOffset, currentOffset + pageSize - 1);
      debugPrint('response: $response');

      final nextItems = (response as List)
          .map((e) => NotificationItem.fromJson(e))
          .toList();

      if (nextItems.isNotEmpty) {
        notifications.addAll(nextItems);
        currentOffset += nextItems.length;
        hasMoreData.value = nextItems.length == pageSize;

        // Mark unread as read if any
        // _markUnreadAsReadInDB(nextItems);
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      debugPrint('Notification load more error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    if (currentUserId.value.isEmpty) return;

    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', currentUserId.value)
          .eq('is_read', false)
          .isFilter('deleted_at', null);

      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      notifications.refresh();
    } catch (e) {
      debugPrint('Mark all as read error: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);

      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifications.refresh();
      }
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  // Future<void> _markUnreadAsReadInDB(List<NotificationItem> items) async {
  //   final unreadIds = items.where((n) => !n.isRead).map((n) => n.id).toList();
  //   if (unreadIds.isEmpty) return;

  //   try {
  //     await SupabaseService.client
  //         .from('notifications')
  //         .update({'is_read': true})
  //         .inFilter('id', unreadIds);

  //     // Update local state for these specific items
  //     for (var id in unreadIds) {
  //       final index = notifications.indexWhere((n) => n.id == id);
  //       if (index != -1) {
  //         notifications[index] = notifications[index].copyWith(isRead: true);
  //       }
  //     }
  //     notifications.refresh();
  //   } catch (e) {
  //     debugPrint('Auto mark read error: $e');
  //   }
  // }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> handleNotificationTap(NotificationItem item) async {
    if (!item.isRead) {
      await markAsRead(item.id);
    }

    final type = (item.relatedEntityType ?? '').toLowerCase();
    final entityId = item.relatedEntityId;

    if (type.isEmpty || entityId == null) {
      Get.offAllNamed(Routes.BOTTOM_BAR);
      return;
    }

    Get.offAllNamed(Routes.BOTTOM_BAR);

    Future.delayed(const Duration(milliseconds: 200), () async {
      BottomBarController? bottomBarController;
      if (Get.isRegistered<BottomBarController>()) {
        bottomBarController = Get.find<BottomBarController>();
      }

      switch (type) {
        case 'weekly_riddles':
        case 'weekly_riddle':
          if (bottomBarController != null) {
            bottomBarController.changeTab(0, true);
          }
          if (Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            await homeController.loadWeeklyRiddle();
            homeController.onRiddleSubmitTap();
          }
          break;

        case 'content':
          if (bottomBarController != null) {
            bottomBarController.changeTab(3, true);
          }
          break;

        case 'assignment':
          if (bottomBarController != null) {
            bottomBarController.changeTab(2, true);
          }
          break;

        case 'event_registration':
        case 'event':
          if (bottomBarController != null) {
            bottomBarController.changeTab(4, true);
          }
          break;

        case 'store_order':
          Get.toNamed(Routes.STORE);
          break;

        default:
          if (bottomBarController != null) {
            bottomBarController.changeTab(0, true);
          }
      }
    });
  }
}
