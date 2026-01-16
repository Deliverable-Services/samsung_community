import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/content_card.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/home_item_model.dart';
import '../../../data/models/store_product_model.dart';
import '../../../data/models/weekly_riddle_model.dart';
import '../../academy/views/assignment_card.dart';
import '../../events/controllers/events_controller.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadLatestItems();
        await controller.loadAllItems();
      },
      child: Obx(() {
        if (controller.isLoadingLatestItems.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: controller.scrollController ?? ScrollController(),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
          children: [
            DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Latest Event
                  if (controller.latestEvent.value != null) ...[
                    _buildEventCard(controller.latestEvent.value!),
                    SizedBox(height: 16.h),
                  ],

                  // Weekly Riddle
                  if (controller.weeklyRiddle.value != null) ...[
                    AssignmentCard(
                      type: AssignmentCardType.riddle,
                      title: controller.weeklyRiddle.value?.title ?? "",
                      description:
                          controller.weeklyRiddle.value?.description ?? '',
                      pointsToEarn: controller.weeklyRiddle.value?.pointsToEarn,
                      isAudio:
                          controller.weeklyRiddle.value?.solutionType ==
                          RiddleSolutionType.audio,
                      audioUrl:
                          controller.weeklyRiddle.value?.solutionType ==
                              RiddleSolutionType.audio
                          ? controller.weeklyRiddle.value?.answer
                          : null,
                      isSubmitted: controller.hasSubmittedRiddle.value,
                      onButtonTap: controller.onRiddleSubmitTap,
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Latest VOD
                  if (controller.latestVod.value != null) ...[
                    _buildVodCard(controller.latestVod.value!),
                    SizedBox(height: 16.h),
                  ],

                  // Latest Podcast
                  if (controller.latestPodcast.value != null) ...[
                    _buildPodcastCard(controller.latestPodcast.value!),
                    SizedBox(height: 16.h),
                  ],

                  // Infinite Scroll List
                  ...controller.allItems.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildItemCard(item),
                    ),
                  ),

                  // Loading indicator for infinite scroll
                  if (controller.isLoadingMore.value)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEventCard(EventModel event) {
    // Safely get EventsController - create if not found
    EventsController eventsController;
    try {
      eventsController = Get.find<EventsController>();
    } catch (_) {
      eventsController = Get.put(EventsController());
    }

    return AllEventLaunchCard(
      imagePath: AppImages.eventLaunchCard,
      imagePathNetwork: event.imageUrl,
      title: event.title,
      description: event.description ?? '',
      exclusiveEvent: true,
      buttonText: "eventDetailsRegistration".tr,
      onButtonTap: () => eventsController.showEventDetailsModal(event),
      labels: [
        EventLabel(text: eventsController.formatEventDate(event.eventDate)),
        if (event.accessType == EventAccessType.internal &&
            event.costPoints != null &&
            event.costPoints! > 0)
          EventLabel(text: 'Points: ${event.costPoints}'),
        if (event.accessType == EventAccessType.external &&
            event.costCreditCents != null &&
            event.costCreditCents! > 0)
          EventLabel(
            text: () {
              debugPrint(
                'Event credits (Home): ${event.title} -> ${event.costCreditCents}',
              );
              return 'Credits: ${event.costCreditCents}';
            }(),
          ),
        EventLabel(
          text: event.maxTickets != null
              ? '${eventsController.getRemainingTickets(event)} ${'remaining'.tr}'
              : 'Unlimited',
        ),
      ],
    );
  }

  Widget _buildVodCard(ContentModel vod) {
    final mediaUrl =
        vod.mediaFileUrl ??
        (vod.mediaFiles != null && vod.mediaFiles!.isNotEmpty
            ? vod.mediaFiles!.first
            : null);
    final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;

    return ContentCard1(
      title: vod.title ?? '',
      description: vod.description ?? '',
      videoUrl: hasMedia ? mediaUrl : null,
      thumbnailUrl: vod.thumbnailUrl,
      thumbnailImage: vod.thumbnailUrl,
      showVideoPlayer: hasMedia,
      showSolutionButton: false,
      onTap: () {
        // TODO: Navigate to VOD details
      },
    );
  }

  Widget _buildPodcastCard(ContentModel podcast) {
    final mediaUrl =
        podcast.mediaFileUrl ??
        (podcast.mediaFiles != null && podcast.mediaFiles!.isNotEmpty
            ? podcast.mediaFiles!.first
            : null);
    final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;

    return ContentCard1(
      title: podcast.title ?? '',
      description: podcast.description ?? '',
      audioUrl: hasMedia ? mediaUrl : null,
      thumbnailUrl: podcast.thumbnailUrl,
      thumbnailImage: podcast.thumbnailUrl,
      showAudioPlayer: hasMedia,
      showSolutionButton: false,
      onTap: () {
        // TODO: Navigate to podcast details
      },
    );
  }

  Widget _buildStoreCard(StoreProductModel product) {
    // StoreCard expects asset path, but we have network URL
    // Use CachedNetworkImage or similar for network images
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          stops: [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, 7.43.h),
            blurRadius: 16.6.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 68.w,
                height: 86.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    width: 2,
                    color: AppColors.textWhiteOpacity60,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          width: 68.w,
                          height: 86.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                AppImages.eventLaunchCard,
                                width: 68.w,
                                height: 86.h,
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset(
                          AppImages.eventLaunchCard,
                          width: 68.w,
                          height: 86.h,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.textWhite,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: 250.w,
                      child: Text(
                        product.description ?? '',
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontSize: 14.sp,
                          height: 22 / 14,
                          letterSpacing: 0,
                          color: AppColors.textWhiteSecondary,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(HomeItem item) {
    switch (item.type) {
      case HomeItemType.event:
        return _buildEventCard(item.event!);
      case HomeItemType.weeklyRiddle:
        return AssignmentCard(
          type: AssignmentCardType.riddle,
          title: item.riddle!.title,
          description: item.riddle!.description ?? '',
          pointsToEarn: item.riddle!.pointsToEarn,
          isAudio: item.riddle!.solutionType == RiddleSolutionType.audio,
          audioUrl: item.riddle!.solutionType == RiddleSolutionType.audio
              ? item.riddle!.answer
              : null,
          isSubmitted: false, // Check if needed
          onButtonTap: controller.onRiddleSubmitTap,
        );
      case HomeItemType.vod:
        return _buildVodCard(item.vod!);
      case HomeItemType.podcast:
        return _buildPodcastCard(item.podcast!);
      case HomeItemType.storeProduct:
        return _buildStoreCard(item.storeProduct!);
    }
  }
}
