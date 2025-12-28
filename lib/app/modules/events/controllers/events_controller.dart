import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/services/event_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/models/event_model.dart';

class EventsController extends BaseController {
  final EventService eventService;

  final RxList<EventModel> allEventsList = <EventModel>[].obs;
  final RxList<EventModel> myEventsList = <EventModel>[].obs;

  final RxBool isLoadingAllEvents = false.obs;
  final RxBool isLoadingMyEvents = false.obs;
  final RxBool hasMoreAllEvents = true.obs;
  final RxBool hasMoreMyEvents = true.obs;

  static const int pageSize = 10;
  int allEventsOffset = 0;
  int myEventsOffset = 0;

  TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? searchDebounceTimer;

  EventsController({EventService? eventService})
      : eventService = eventService ?? EventService();

  late final ScrollController allEventsScrollController;
  late final ScrollController myEventsScrollController;

  @override
  void onInit() {
    super.onInit();
    allEventsScrollController = ScrollController();
    myEventsScrollController = ScrollController();
    allEventsScrollController.addListener(_onAllEventsScroll);
    myEventsScrollController.addListener(_onMyEventsScroll);
    searchController.addListener(_onSearchChanged);
    loadAllEvents();
    loadMyEvents();
  }

  @override
  void onClose() {
    allEventsScrollController.removeListener(_onAllEventsScroll);
    myEventsScrollController.removeListener(_onMyEventsScroll);
    allEventsScrollController.dispose();
    myEventsScrollController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchDebounceTimer?.cancel();
    super.onClose();
  }

  void _onAllEventsScroll() {
    if (allEventsScrollController.position.pixels >=
        allEventsScrollController.position.maxScrollExtent * 0.8) {
      if (!isLoadingAllEvents.value && hasMoreAllEvents.value) {
        loadMoreAllEvents();
      }
    }
  }

  void _onMyEventsScroll() {
    if (myEventsScrollController.position.pixels >=
        myEventsScrollController.position.maxScrollExtent * 0.8) {
      if (!isLoadingMyEvents.value && hasMoreMyEvents.value) {
        loadMoreMyEvents();
      }
    }
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    searchDebounceTimer?.cancel();
    searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadAllEvents();
      loadMyEvents();
    });
  }

  Future<void> loadAllEvents({bool loadMore = false}) async {
    if (isLoadingAllEvents.value) return;

    if (!loadMore) {
      allEventsOffset = 0;
      allEventsList.clear();
      hasMoreAllEvents.value = true;
    }

    isLoadingAllEvents.value = true;

    try {
      final result = await eventService.getEvents(
        isPublished: true,
        limit: pageSize,
        offset: allEventsOffset,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (result is Success<List<EventModel>>) {
        final events = result.data;
        if (loadMore) {
          allEventsList.addAll(events);
        } else {
          allEventsList.value = events;
        }
        allEventsOffset += events.length;
        hasMoreAllEvents.value = events.length >= pageSize;
      } else if (result is Failure<List<EventModel>>) {
        CommonSnackbar.error(result.message);
      }
    } catch (e) {
      CommonSnackbar.error('somethingWentWrong'.tr);
    } finally {
      isLoadingAllEvents.value = false;
    }
  }

  Future<void> loadMoreAllEvents() async {
    await loadAllEvents(loadMore: true);
  }

  Future<void> loadMyEvents({bool loadMore = false}) async {
    if (isLoadingMyEvents.value) return;

    final currentUserId = SupabaseService.currentUser?.id;
    if (currentUserId == null) {
      myEventsList.clear();
      isLoadingMyEvents.value = false;
      return;
    }

    if (!loadMore) {
      myEventsOffset = 0;
      myEventsList.clear();
      hasMoreMyEvents.value = true;
    }

    isLoadingMyEvents.value = true;

    try {
      final result = await eventService.getUserEvents(
        userId: currentUserId,
        isPublished: true,
        limit: pageSize,
        offset: myEventsOffset,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (result is Success<List<EventModel>>) {
        final events = result.data;
        if (loadMore) {
          myEventsList.addAll(events);
        } else {
          myEventsList.value = events;
        }
        myEventsOffset += events.length;
        hasMoreMyEvents.value = events.length >= pageSize;
      } else if (result is Failure<List<EventModel>>) {
        CommonSnackbar.error(result.message);
      }
    } catch (e) {
      CommonSnackbar.error('somethingWentWrong'.tr);
    } finally {
      isLoadingMyEvents.value = false;
    }
  }

  Future<void> loadMoreMyEvents() async {
    await loadMyEvents(loadMore: true);
  }

  String formatEventDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  int getRemainingTickets(EventModel event) {
    if (event.maxTickets == null) {
      return 0; // Unlimited
    }
    return (event.maxTickets! - event.ticketsSold).clamp(0, event.maxTickets!);
  }
}
