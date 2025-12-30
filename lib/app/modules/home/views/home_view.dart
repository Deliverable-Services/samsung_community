import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
import '../../../data/helper_widgets/store_card.dart';
import '../../../data/models/weekly_riddle_model.dart';
import '../../academy/views/assignment_card.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadWeeklyRiddle(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EventLaunchCard(
                  imagePath: AppImages.eventLaunchCard,
                  title: 'homeExclusiveLaunchEvent'.tr,
                  description: 'homeLoramDescription'.tr,
                  text: '08.12.2025',
                  showButton: true,
                  onButtonTap: () {
                    // TODO: Handle button tap
                  },
                  exclusiveEvent: true,
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  if (controller.isLoadingRiddle.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final riddle = controller.weeklyRiddle.value;
                  if (riddle == null) {
                    return const SizedBox.shrink();
                  }
                  return AssignmentCard(
                    type: AssignmentCardType.riddle,
                    title: riddle.title,
                    description: riddle.description ?? '',
                    pointsToEarn: riddle.pointsToEarn,
                    isAudio: riddle.solutionType == RiddleSolutionType.audio,
                    audioUrl: riddle.solutionType == RiddleSolutionType.audio
                        ? riddle.answer
                        : null,
                    isSubmitted: controller.hasSubmittedRiddle.value,
                    onButtonTap: controller.onRiddleSubmitTap,
                  );
                }),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(214, 214, 214, 0.14),
                        Color.fromRGBO(112, 112, 112, 0.14),
                      ],
                      stops: [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1A000000),
                        offset: Offset(0, 7.43.h),
                        blurRadius: 16.6.r,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: EventLaunchCard(
                    imagePath: AppImages.eventRegisteration,
                    title: 'homeLiveEventRegistration'.tr,
                    description: 'homeLiveEventDescription'.tr,
                    text: 'homeMoreDetails'.tr,
                    showButton: true,
                    onButtonTap: () {
                      // TODO: Navigate to Eventer payment screen
                    },
                    exclusiveEvent: false,
                    extraPaddingForButton: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ),
                    labels: [
                      EventLabel(
                        widget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              child: SvgPicture.asset(
                                AppImages.pointsIcon,
                                width: 18.w,
                                height: 18.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'homePoints'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                                letterSpacing: 0,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
                        onTap: () {
                          // TODO: Handle button tap
                        },
                      ),
                      EventLabel(
                        text: '08.12.2025',
                        onTap: () {
                          // TODO: Handle button tap
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                StoreCard(
                  imagePath: AppImages.eventLaunchCard,
                  title: 'homePodcastsLuxuryStores'.tr,
                  description: 'homeLoremDescription'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
