import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../common/services/event_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/models/event_model.dart';
import '../../store/local_widgets/product_detail.dart';
import '../local_widgets/event_email_modal.dart';
import '../../../data/constants/app_images.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class EventsController extends BaseController {
  final EventService eventService;

  final RxList<EventModel> allEventsList = <EventModel>[].obs;
  final RxList<EventModel> myEventsList = <EventModel>[].obs;

  final RxBool isLoadingAllEvents = false.obs;
  final RxBool isLoadingMyEvents = false.obs;
  final RxBool hasMoreAllEvents = true.obs;
  final RxBool hasMoreMyEvents = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxSet<String> registeredEventIds = <String>{}.obs;

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
    fetchRegisteredUserEvents();
  }

  Future<void> fetchRegisteredUserEvents() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await SupabaseService.client
          .from('event_registrations')
          .select('event_id')
          .eq('user_id', userId);

      final ids = (response as List)
          .map((e) => e['event_id'] as String)
          .toSet();
      
      debugPrint('Fetched registered IDs: $ids');
      registeredEventIds.assignAll(ids);
    } catch (e) {
      debugPrint('Error fetching registered events: $e');
    }
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
      allEventsOffset = 0;
      allEventsList.value = <EventModel>[];
      hasMoreAllEvents.value = true;
      await fetchRegisteredUserEvents();
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
          allEventsList.assignAll(events.toList());
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
      myEventsList.value = <EventModel>[];
      isLoadingMyEvents.value = false;
      return;
    }

    if (!loadMore) {
      myEventsOffset = 0;
      myEventsList.value = <EventModel>[];
      hasMoreMyEvents.value = true;
      await fetchRegisteredUserEvents();
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
          myEventsList.assignAll(events.toList());
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

  /// Show event details modal - reusable method
  Future<bool> registerEventWithPoints(EventModel event) async {
    if (isPurchasing.value) return false;
    isPurchasing.value = true;

    try {
      final currentUserId = SupabaseService.currentUser?.id;
      if (currentUserId == null) {
        CommonSnackbar.error('User not authenticated');
        return false;
      }

      final authRepo = Get.find<AuthRepo>();
      final currentUser = authRepo.currentUser.value;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return false;
      }

      final int costPoints = event.costPoints ?? 0;
      final currentPoints = currentUser.pointsBalance;

      // Check if already registered
      final existingRegistration = await SupabaseService.client
          .from('event_registrations')
          .select('id')
          .eq('event_id', event.id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existingRegistration != null) {
        CommonSnackbar.success('You are already registered for this event');
        return true;
      }

      if (currentPoints < costPoints) {
        CommonSnackbar.error('insufficientPoints'.tr);
        return false;
      }

      final balanceAfter = currentPoints - costPoints;

      debugPrint('Starting registration logic...');

      // 1. Create Event Registration
      debugPrint('Inserting event_registration for event: ${event.id}, user: $currentUserId');
      try {
        final registrationResponse = await SupabaseService.client
            .from('event_registrations')
            .insert({
              'event_id': event.id,
              'user_id': currentUserId,
              'payment_method': 'points',
              'points_paid': costPoints,
              'status': 'registered',
              'registered_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select('id')
            .single();
        
        debugPrint('Registration inserted. ID: ${registrationResponse['id']}');
        final registrationId = registrationResponse['id'] as String;

        // 2. Create Points Transaction
        debugPrint('Inserting points_transaction...');
        await SupabaseService.client.from('points_transactions').insert({
          'user_id': currentUserId,
          'transaction_type': 'spent',
          'amount': -costPoints,
          'balance_after': balanceAfter,
          'description': 'Event Registration: ${event.title}',
          'related_entity_type': 'event_registration',
          'related_entity_id': registrationId,
        });
        debugPrint('Points transaction inserted.');

        // 3. Update User Balance
        debugPrint('Updating user balance...');
        await SupabaseService.client
            .from('users')
            .update({'points_balance': balanceAfter})
            .eq('id', currentUserId);
        debugPrint('User balance updated.');

        // 4. Refresh User Data
        await authRepo.loadCurrentUser();

        // 5. Refresh Events List
        loadAllEvents();
        loadMyEvents();
        registeredEventIds.add(event.id);

        CommonSnackbar.success('Successfully registered for ${event.title}');
        return true;
      } catch (insertError) {
        debugPrint('Error during Supabase operation: $insertError');
        rethrow; // Pass to outer catch
      }
    } catch (e) {
      debugPrint('Error registering for event (Outer): $e');
      if (e.toString().contains('unique')) {
        CommonSnackbar.error('You are already registered for this event');
      } else {
        CommonSnackbar.error('Error: $e');
      }
      return false;
    } finally {
      isPurchasing.value = false;
    }
  }

  void showEventDetailsModal(EventModel event) {
    // ... existing implementation ...
    final context = Get.context;
    if (context == null) return;

    // Build description with event details
    String description = event.description ?? '';

    // Top tablets - date
    final List<String> topTablets = [formatEventDate(event.eventDate)];

    // Middle tablets - points and credit
    final List<String> middleTablets = [];
    if (event.costCreditCents != null && event.costCreditCents! > 0) {
      middleTablets.add(
        'Credits: ${(event.costCreditCents! / 100).toStringAsFixed(0)}',
      );
    }
    if (event.costPoints != null && event.costPoints! > 0) {
      middleTablets.add('Points: ${event.costPoints}');
    }

    // Media URL - prefer video, then image, then fallback asset
    final bool hasVideo =
        event.videoUrl != null && event.videoUrl!.trim().isNotEmpty;

    final String mediaUrl = hasVideo
        ? event.videoUrl!
        : (event.imageUrl != null && event.imageUrl!.trim().isNotEmpty)
        ? event.imageUrl!
        : AppImages.eventLaunchCard;

    final bool isVideo = hasVideo;

    // Bottom button
    final bool hasCost =
        (event.costPoints != null && event.costPoints! > 0) ||
        (event.costCreditCents != null && event.costCreditCents! > 0);

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: Obx(() {
        final bool isRegistered = registeredEventIds.contains(event.id);

        final String buttonText = isRegistered 
            ? 'Registered' 
            : (hasCost ? 'Buying' : 'Register');

        final VoidCallback? buttonOnTap = isRegistered 
            ? null 
            : () {
                // Close the product detail modal first
                Get.back();
                // Show email input modal
                EventEmailModal.show(
                  context,
                  eventId: event.id,
                  costPoints: event.costPoints,
                  eventModel: event,
                );
              };

        return ProductDetail(
          topTablets: topTablets,
          title: event.title,
          description: description,
          middleTablets: middleTablets.isNotEmpty ? middleTablets : null,
          mediaUrl: mediaUrl,
          isVideo: isVideo,
          bottomButtonText: buttonText,
          bottomButtonOnTap: buttonOnTap ?? () {},
          isButtonEnabled: !isRegistered,
          tag: 'event_${event.id}',
        );
      }),
    );
  }
}
