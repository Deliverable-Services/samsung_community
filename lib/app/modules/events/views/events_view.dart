import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
import '../../../data/models/event_model.dart';
import '../controllers/events_controller.dart';

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
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              _buildSearchBarForAllEvent(),
              SizedBox(height: 200.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Text(
                    'noEventsFound'.tr,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.allEventsScrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            _buildSearchBarForAllEvent(),
            SizedBox(height: 20.h),
            ...controller.allEventsList.map((event) {
              final List<EventLabel> labels = [
                EventLabel(text: controller.formatEventDate(event.eventDate)),
              ];

              if (event.accessType == EventAccessType.internal) {
                if (event.costPoints != null && event.costPoints! > 0) {
                  labels.add(EventLabel(text: 'Points: ${event.costPoints}'));
                }
              } else {
                if (event.costCreditCents != null &&
                    event.costCreditCents! > 0) {
                  debugPrint(
                    'Event credits (All Events): ${event.title} -> ${event.costCreditCents}',
                  );
                  labels.add(
                    EventLabel(text: 'Credits: ${event.costCreditCents}'),
                  );
                }
              }

              labels.add(
                EventLabel(
                  text: event.maxTickets != null
                      ? '${controller.getRemainingTickets(event)} ${'remaining'.tr}'
                      : 'Unlimited',
                ),
              );

              return Column(
                children: [
                  AllEventLaunchCard(
                    imagePath: AppImages.eventLaunchCard,
                    imagePathNetwork: event.imageUrl,
                    title: event.title,
                    description: event.description ?? '',
                    exclusiveEvent: true,
                    buttonText: "eventDetailsRegistration".tr,
                    onButtonTap: () => controller.showEventDetailsModal(event),
                    labels: labels,
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }),
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
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              _buildSearchBar(),
              SizedBox(height: 200.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Text(
                    'noMyEventsFound'.tr,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.myEventsScrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            _buildSearchBar(),
            SizedBox(height: 20.h),
            ...controller.myEventsList.map((event) {
              final List<EventLabel> labels = [
                EventLabel(text: controller.formatEventDate(event.eventDate)),
              ];

              if (event.accessType == EventAccessType.internal) {
                if (event.costPoints != null && event.costPoints! > 0) {
                  labels.add(EventLabel(text: 'Points: ${event.costPoints}'));
                }
              } else {
                if (event.costCreditCents != null &&
                    event.costCreditCents! > 0) {
                  debugPrint(
                    'Event credits (My Events): ${event.title} -> ${event.costCreditCents}',
                  );
                  labels.add(
                    EventLabel(text: 'Credits: ${event.costCreditCents}'),
                  );
                }
              }

              return Column(
                children: [
                  AllEventLaunchCard(
                    imagePath: AppImages.eventLaunchCard,
                    imagePathNetwork: event.imageUrl,
                    title: event.title,
                    description: event.description ?? '',
                    exclusiveEvent: true,
                    buttonText: 'details'.tr,
                    onButtonTap: () => controller.showEventDetailsModal(event),
                    labels: labels,
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }),
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
