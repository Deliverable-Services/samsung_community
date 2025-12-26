import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
import '../../../data/models/event_model.dart';
import '../../store/local_widgets/product_detail.dart';
import '../controllers/events_controller.dart';
import '../local_widgets/event_email_modal.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: _buildHeader(),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    indicatorColor: const Color(0xFF6EA8FF),
                    indicatorWeight: 2,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'allEvents'.tr),
                      Tab(text: 'myEvents'.tr),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [_buildAllEventsTab(), _buildMyEventsTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildAllEventsTab() {
    return RefreshIndicator(
      onRefresh: () => controller.loadAllEvents(),
      child: Obx(() {
        if (controller.isLoadingAllEvents.value &&
            controller.allEventsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allEventsList.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Text(
                'noEventsFound'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return ListView(
          controller: controller.allEventsScrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            _buildSearchBarForAllEvent(),
            SizedBox(height: 20.h),
            ...controller.allEventsList.map((event) {
              return Column(
                children: [
                  AllEventLaunchCard(
                    imagePath: AppImages.eventLaunchCard,
                    imagePathNetwork: event.imageUrl,
                    title: event.title,
                    description: event.description ?? '',
                    exclusiveEvent: true,
                    buttonText: "Details & Registration",
                    onButtonTap: () => _showEventDetailsModal(event),
                    labels: [
                      EventLabel(
                        text: controller.formatEventDate(event.eventDate),
                      ),
                      EventLabel(
                        text: event.maxTickets != null
                            ? '${controller.getRemainingTickets(event)} ${'remaining'.tr}'
                            : 'Unlimited',
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }).toList(),
            if (controller.isLoadingAllEvents.value &&
                controller.allEventsList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildMyEventsTab() {
    return RefreshIndicator(
      onRefresh: () => controller.loadMyEvents(),
      child: Obx(() {
        if (controller.isLoadingMyEvents.value &&
            controller.myEventsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myEventsList.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Text(
                'noMyEventsFound'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return ListView(
          controller: controller.myEventsScrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            _buildSearchBar(),
            SizedBox(height: 20.h),
            ...controller.myEventsList.map((event) {
              return Column(
                children: [
                  EventLaunchCard(
                    imagePath: AppImages.eventLaunchCard,
                    imagePathNetwork: event.imageUrl,
                    title: event.title,
                    description: event.description ?? '',
                    text: controller.formatEventDate(event.eventDate),
                    buttonText: 'details'.tr,
                    showButton: true,
                    exclusiveEvent: event.eventType == EventType.liveEvent,
                    onButtonTap: () => _showEventDetailsModal(event),
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }).toList(),
            if (controller.isLoadingMyEvents.value &&
                controller.myEventsList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'communityEvents'.tr,
          style: const TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            height: 24 / 16,
            letterSpacing: 0,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.only(right: 30.w),
          child: Text(
            'uniqueExperiences'.tr,
            style: const TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontStyle: FontStyle.normal,
              fontSize: 14,
              height: 22 / 14,
              letterSpacing: 0,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarForAllEvent() {
    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 13.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [AppColors.searchGradientStart, AppColors.searchGradientEnd],
          stops: [0, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Row(
          children: [
            Image.asset(
              AppImages.searchIcon,
              width: 22.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontStyle: FontStyle.normal,
                  fontSize: 14.sp,
                  height: 24 / 14,
                  letterSpacing: 0,
                  color: AppColors.white.withOpacity(0.4),
                ),
                decoration: InputDecoration(
                  hintText: 'exploreOurEvents'.tr,
                  hintStyle: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontStyle: FontStyle.normal,
                    fontSize: 14.sp,
                    height: 24 / 14,
                    letterSpacing: 0,
                    color: AppColors.white.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                  },
                  child: Icon(
                    Icons.clear,
                    color: AppColors.white.withOpacity(0.4),
                    size: 20.sp,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 13.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [AppColors.searchGradientStart, AppColors.searchGradientEnd],
          stops: [0, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Row(
          children: [
            Image.asset(
              AppImages.searchIcon,
              width: 22.w,
              height: 24.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontStyle: FontStyle.normal,
                  fontSize: 14.sp,
                  height: 24 / 14,
                  letterSpacing: 0,
                  color: AppColors.white.withOpacity(0.4),
                ),
                decoration: InputDecoration(
                  hintText: 'search'.tr,
                  hintStyle: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontStyle: FontStyle.normal,
                    fontSize: 14.sp,
                    height: 24 / 14,
                    letterSpacing: 0,
                    color: AppColors.white.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                  },
                  child: Icon(
                    Icons.clear,
                    color: AppColors.white.withOpacity(0.4),
                    size: 20.sp,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  void _showEventDetailsModal(EventModel event) {
    final context = Get.context;
    if (context == null) return;

    // Build description with event details
    String description = event.description ?? '';

    // Top tablets - date
    final List<String> topTablets = [
      controller.formatEventDate(event.eventDate),
    ];

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

    // Media URL - prefer video, then image
    final String? mediaUrl =
        event.videoUrl != null && event.videoUrl!.isNotEmpty
        ? event.videoUrl
        : event.imageUrl;
    final bool isVideo = event.videoUrl != null && event.videoUrl!.isNotEmpty;

    // Bottom button
    String? buttonText;
    VoidCallback? buttonOnTap;
    if ((event.costPoints != null && event.costPoints! > 0) ||
        (event.costCreditCents != null && event.costCreditCents! > 0)) {
      buttonText = 'Buying';
      buttonOnTap = () {
        // Close the product detail modal first
        Get.back();
        // Show email input modal
        EventEmailModal.show(
          context,
          onNext: () {
            // TODO: Handle event purchase/registration with email
          },
        );
      };
    }

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: ProductDetail(
        topTablets: topTablets,
        title: event.title,
        description: description,
        middleTablets: middleTablets.isNotEmpty ? middleTablets : null,
        mediaUrl: mediaUrl,
        isVideo: isVideo,
        bottomButtonText: buttonText,
        bottomButtonOnTap: buttonOnTap,
        isButtonEnabled: true,
        tag: 'event_${event.id}',
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.primary, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
