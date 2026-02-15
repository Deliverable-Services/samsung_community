import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../common/services/event_service.dart';
import '../../../common/services/event_tracking_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/models/event_model.dart';
import '../../store/local_widgets/product_detail.dart';
import '../local_widgets/event_email_modal.dart';
import '../local_widgets/event_registration_success_modal.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/event_buying_bottom_bar_modal.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../../routes/app_pages.dart';

class EventsController extends BaseController {
  final EventService eventService;

  final RxList<EventModel> allEventsList = <EventModel>[].obs;
  final RxList<EventModel> myEventsList = <EventModel>[].obs;

  final RxBool isLoadingAllEvents = false.obs;
  final RxBool isLoadingMyEvents = false.obs;
  final RxBool hasMoreAllEvents = true.obs;
  final RxBool hasMoreMyEvents = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isCancelling = false.obs;
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
    if (allEventsScrollController.positions.length != 1) return;
    if (allEventsScrollController.position.pixels >=
        allEventsScrollController.position.maxScrollExtent * 0.8) {
      if (!isLoadingAllEvents.value && hasMoreAllEvents.value) {
        loadMoreAllEvents();
      }
    }
  }

  void _onMyEventsScroll() {
    if (myEventsScrollController.positions.length != 1) return;
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
        final events = result.data
            .where((e) =>
                e.maxTickets == null || e.ticketsSold < e.maxTickets!)
            .toList();
        if (loadMore) {
          allEventsList.addAll(events);
        } else {
          allEventsList.assignAll(events);
        }
        allEventsOffset += result.data.length;
        hasMoreAllEvents.value = result.data.length >= pageSize;
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

  void _updateEventInLists(EventModel updated) {
    final allIndex = allEventsList.indexWhere((e) => e.id == updated.id);
    if (allIndex != -1) {
      allEventsList[allIndex] = updated;
      allEventsList.refresh();
    }
    final myIndex = myEventsList.indexWhere((e) => e.id == updated.id);
    if (myIndex != -1) {
      myEventsList[myIndex] = updated;
      myEventsList.refresh();
    }
  }

  /// Show event details modal - reusable method
  Future<bool> registerEventWithPoints(
    EventModel event, {
    String? emailForTickets,
  }) async {
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
        debugPrint(
          'Analytics: user does not have enough points to register for an internal event',
        );
        await EventTrackingService.trackEvent(
          eventType: 'event_registration_insufficient_points',
          eventProperties: {
            'event_id': event.id,
            'event_title': event.title,
            'cost_points': costPoints,
            'current_points': currentPoints,
          },
        );
        CommonSnackbar.error('insufficientPoints'.tr);
        return false;
      }

      final balanceAfter = currentPoints - costPoints;

      debugPrint('Starting registration logic...');

      // 1. Create Event Registration
      debugPrint(
        'Inserting event_registration for event: ${event.id}, user: $currentUserId',
      );
      try {
        final registrationResponse = await SupabaseService.client
            .from('event_registrations')
            .insert({
              'event_id': event.id,
              'user_id': currentUserId,
              if (emailForTickets != null && emailForTickets.isNotEmpty)
                'email_for_tickets': emailForTickets,
              'payment_method': 'points',
              'points_paid': costPoints,
              'status': 'registered',
              'registered_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select('id')
            .single();

        debugPrint('Registration inserted. ID: ${registrationResponse['id']}');
        final registrationId = registrationResponse['id'] as String;

        // 1b. Increment tickets_sold on the event
        final eventRow = await SupabaseService.client
            .from('events')
            .select('tickets_sold')
            .eq('id', event.id)
            .single();
        final currentTicketsSold = eventRow['tickets_sold'] as int? ?? 0;
        await SupabaseService.client
            .from('events')
            .update({'tickets_sold': currentTicketsSold + 1})
            .eq('id', event.id);

        // 2. Create Points Transaction
        debugPrint('Inserting points_transaction...');
        debugPrint(
          'Analytics: creating points transaction for event registration',
        );
        debugPrint(
          'Analytics: awarding points: $costPoints to user: $currentUserId',
        );
        await EventTrackingService.trackEvent(
          eventType: 'event_registration_points_transaction',
          eventProperties: {
            'amount': -costPoints,
            'event_id': event.id,
            'user_id': currentUserId,
          },
        );
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

        // 5. Update event in lists so remaining shows X-1 immediately
        _updateEventInLists(event.copyWith(ticketsSold: event.ticketsSold + 1));
        registeredEventIds.add(event.id);
        loadAllEvents();
        loadMyEvents();

        CommonSnackbar.success('subscribedSuccessfullyToTheEvent'.tr);
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

  Future<bool> cancelEventRegistration(EventModel event) async {
    if (isCancelling.value) return false;
    isCancelling.value = true;

    try {
      final currentUserId = SupabaseService.currentUser?.id;
      if (currentUserId == null) {
        CommonSnackbar.error('User not authenticated');
        return false;
      }

      final existingRegistration = await SupabaseService.client
          .from('event_registrations')
          .select('id, points_paid')
          .eq('event_id', event.id)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existingRegistration == null) {
        CommonSnackbar.error('Registration not found');
        return false;
      }

      final registrationId = existingRegistration['id'] as String;
      final pointsToRefund = existingRegistration['points_paid'] as int? ?? 0;

      await SupabaseService.client
          .from('event_registrations')
          .delete()
          .eq('id', registrationId);

      if (pointsToRefund > 0) {
        final userRow = await SupabaseService.client
            .from('users')
            .select('points_balance')
            .eq('id', currentUserId)
            .single();
        final currentBalance = userRow['points_balance'] as int? ?? 0;
        final balanceAfter = currentBalance + pointsToRefund;

        await SupabaseService.client.from('points_transactions').insert({
          'user_id': currentUserId,
          'transaction_type': 'refunded',
          'amount': pointsToRefund,
          'balance_after': balanceAfter,
          'description': 'Event cancellation refund: ${event.title}',
          'related_entity_type': 'event_registration',
          'related_entity_id': registrationId,
        });

        await SupabaseService.client
            .from('users')
            .update({'points_balance': balanceAfter})
            .eq('id', currentUserId);

        final authRepo = Get.find<AuthRepo>();
        await authRepo.loadCurrentUser();
      }

      final eventRow = await SupabaseService.client
          .from('events')
          .select('tickets_sold')
          .eq('id', event.id)
          .single();

      final currentTicketsSold = eventRow['tickets_sold'] as int? ?? 0;
      final updatedTicketsSold = currentTicketsSold > 0
          ? currentTicketsSold - 1
          : 0;

      await SupabaseService.client
          .from('events')
          .update({'tickets_sold': updatedTicketsSold})
          .eq('id', event.id);

      registeredEventIds.remove(event.id);
      _updateEventInLists(event.copyWith(ticketsSold: updatedTicketsSold));
      loadAllEvents();
      loadMyEvents();
      await fetchRegisteredUserEvents();

      return true;
    } catch (e) {
      debugPrint('Error cancelling event registration: $e');
      CommonSnackbar.error('Error: $e');
      return false;
    } finally {
      isCancelling.value = false;
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

    final bool isInternal = event.accessType == EventAccessType.internal;

    // Middle tablets - points and credit
    final List<String> middleTablets = [];
    if (isInternal) {
      if (event.costPoints != null && event.costPoints! > 0) {
        middleTablets.add('${'points'.tr} ${event.costPoints}');
      }
    } else {
      if (event.costCreditCents != null && event.costCreditCents! > 0) {
        middleTablets.add('Credits: ${event.costCreditCents}');
      }
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
    final bool hasCost = isInternal
        ? (event.costPoints != null && event.costPoints! > 0)
        : (event.costCreditCents != null && event.costCreditCents! > 0);

    final maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      maxHeight: maxSheetHeight,
      content: Obx(() {
        final bool isRegistered = registeredEventIds.contains(event.id);
        final bool isBusy = isPurchasing.value || isCancelling.value;

        final String buttonText = isRegistered
            ? 'cancelEvent'.tr
            : (hasCost ? 'buying'.tr : 'register'.tr);

        final String? buttonIconPath = isRegistered
            ? AppImages.cancelEventIcon
            : null;

        final double? buttonIconSize = isRegistered ? 14.h : null;

        final VoidCallback buttonOnTap = isRegistered
            ? () {
                if (isBusy) return;
                Get.back();

                if (isInternal) {
                  final currentContext = Get.context;
                  if (currentContext == null) return;
                  BottomSheetModal.show(
                    currentContext,
                    buttonType: BottomSheetButtonType.close,
                    content: Obx(
                      () => CancelEventConfirmationModal(
                        isLoading: isCancelling.value,
                        onConfirm: () {
                          debugPrint(
                            'Analytics: user clicked the confirm button to cancel an event registration',
                          );
                          EventTrackingService.trackEvent(
                            eventType: 'event_cancel_confirm_click',
                            eventProperties: {'event_id': event.id},
                          );
                          if (isCancelling.value) return;
                          cancelEventRegistration(event).then((didCancel) {
                            if (!didCancel) return;
                            final popContext = Get.context;
                            if (popContext != null) {
                              final navigator = Navigator.of(
                                popContext,
                                rootNavigator: true,
                              );
                              if (navigator.canPop()) navigator.pop();
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final ctx = Get.context;
                              if (ctx == null) return;
                              BottomSheetModal.show(
                                ctx,
                                content: const EventCancellationSuccessModal(),
                                buttonType: BottomSheetButtonType.none,
                              );
                            });
                          });
                        },
                      ),
                    ),
                  );
                } else {
                  Get.toNamed(
                    Routes.EVENTER_PAYMENT,
                    arguments: {
                      'url': 'https://www.eventer.co.il/orderCancellation',
                    },
                  );
                }
              }
            : () {
                debugPrint(
                  'Analytics: user clicked the register button for an internal event',
                );
                EventTrackingService.trackEvent(
                  eventType: 'event_register_click',
                  eventProperties: {'event_id': event.id},
                );
                if (isBusy) return;
                if (event.maxTickets != null &&
                    getRemainingTickets(event) == 0) {
                  CommonSnackbar.error('noTicketsLeft'.tr);
                  return;
                }
                Get.back();
                final currentContext = Get.context;
                if (currentContext == null) return;

                // Check if user has enough points before showing email modal
                if (isInternal &&
                    event.costPoints != null &&
                    event.costPoints! > 0) {
                  final authRepo = Get.find<AuthRepo>();
                  final currentUser = authRepo.currentUser.value;
                  if (currentUser != null) {
                    final currentPoints = currentUser.pointsBalance;
                    if (currentPoints < event.costPoints!) {
                      _showInsufficientPointsModal(currentContext, event);
                      return;
                    }
                  }
                }

                EventEmailModal.show(
                  currentContext,
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
          bottomButtonIconPath: buttonIconPath,
          bottomButtonIconSize: buttonIconSize,
          bottomButtonOnTap: buttonOnTap ?? () {},
          isButtonEnabled: !isBusy,
          tag: 'event_${event.id}',
        );
      }),
    );
  }

  void _showInsufficientPointsModal(BuildContext context, EventModel event) {
    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: RegistrationSuccessModal(
        icon: AppImages.notEnoughPointsIcon,
        title: "youDoNotHaveEnoughPoints".tr,
        text: "close".tr,
        description: 'yourBalanceIsTooLowToCompleteThisAction'.tr,
        onButtonTap: () {
          Get.back();
        },
      ),
    );
  }
}
