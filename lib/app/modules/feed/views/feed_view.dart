import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/filter_component.dart';
import '../controllers/feed_controller.dart';
import '../local_widgets/feed_card/feed_card.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: controller.loadContent, // 👈 correct refresh call
          child: Obx(() {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // 👈 REQUIRED
                    child: DefaultTextStyle(
                      style: const TextStyle(decoration: TextDecoration.none),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 12.h,
                          bottom: 22.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// 🔍 Search
                            SearchWidget(
                              placeholder: 'searchForInspiration'.tr,
                              controller: controller.searchController,
                              onChanged: controller.onSearchChanged,
                            ),

                            SizedBox(height: 20.h),

                            /// 🟡 Empty state
                            if (controller.filteredContentList.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40.h),
                                  child: Text(
                                    'No content found',
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                ),
                              ),

                            /// 📋 Feed list
                            ...controller.filteredContentList
                                .asMap()
                                .entries
                                .map((entry) {
                                  final content = entry.value;

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 20.h),
                                    child: FeedCard(
                                      authorName:
                                          content.userModel?.fullName ?? '',
                                      authorAvatar:
                                          content
                                              .userModel
                                              ?.profilePictureUrl ??
                                          '',
                                      isVerified: content.isPublished,
                                      publishedDate: DateFormat(
                                        'dd/MM/yy',
                                      ).format(content.createdAt),
                                      title: content.title ?? '',
                                      description: content.description ?? '',
                                      isLiked: content.isFeatured,
                                      likesCount: content.likesCount,
                                      likedByUsername: content.userId,
                                      commentsCount: content.commentsCount,
                                      onMenuTap: () => controller
                                          .showFeedActionModal(content.id),
                                      onReadMore: () => controller.onReadMore(
                                        title: content.title ?? '',
                                        description: content.description ?? '',
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  );
          }),
        ),
        Positioned(
          bottom: -70.h,
          right: -50.w,
          child: GestureDetector(
            onTap: controller.showCreatePostModal,
            child: SizedBox(
              width: 250.w,
              height: 250.h,
              child: Image.asset(AppImages.createPostIcon),
            ),
          ),
        ),
      ],
    );
  }
}
