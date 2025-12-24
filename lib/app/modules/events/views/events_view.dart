import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/event_buying_bottom_bar_modal.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
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
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    _buildSearchBarForAllEvent(),
                    SizedBox(height: 20.h),
                    AllEventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      exclusiveEvent: true,
                      labels: [
                        EventLabel(text: '08.12.2025'),
                        EventLabel(text: '23 Remaining'),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AllEventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      exclusiveEvent: true,
                      labels: [
                        EventLabel(text: '08.12.2025'),
                        EventLabel(text: '23 Remaining'),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AllEventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      exclusiveEvent: true,
                      labels: [
                        EventLabel(text: '08.12.2025'),
                        EventLabel(text: '23 Remaining'),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AllEventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      exclusiveEvent: true,
                      labels: [
                        EventLabel(text: '08.12.2025'),
                        EventLabel(text: '23 Remaining'),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    SizedBox(height: 20.h),
                    EventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      text: '08.12.2025',
                      buttonText: 'details',
                      showButton: true,
                      exclusiveEvent: true,
                      onButtonTap: () {
                        final context = Get.context;
                        if (context == null) return;
                        BottomSheetModal.show(
                          context,
                          buttonType: BottomSheetButtonType.close,
                          content: EventBuyingBottomBarModal(
                            title: 'homeExclusiveLaunchEvent'.tr,
                            description:
                                'orem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore....',
                            text: '08.12.2025',
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    EventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      text: '08.12.2025',
                      buttonText: 'details',
                      showButton: true,
                      exclusiveEvent: true,
                      onButtonTap: () {},
                    ),
                    SizedBox(height: 16.h),
                    EventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      text: '08.12.2025',
                      buttonText: 'details',
                      showButton: true,
                      exclusiveEvent: true,
                      onButtonTap: () {},
                    ),
                    SizedBox(height: 16.h),
                    EventLaunchCard(
                      imagePath: AppImages.eventLaunchCard,
                      title: 'homeExclusiveLaunchEvent'.tr,
                      description: 'homeLoramDescription'.tr,
                      text: '08.12.2025',
                      buttonText: 'details',
                      showButton: true,
                      exclusiveEvent: true,
                      onButtonTap: () {},
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
