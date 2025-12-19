import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/constants/feed_content.dart';
import '../../../data/helper_widgets/feed_card.dart';
import '../../../data/helper_widgets/filter_component.dart';

import '../controllers/feed_controller.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 22.h,
                bottom: 22.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchWidget(placeholder: 'searchForInspiration'.tr),
                  SizedBox(height: 20.h),
                  ...FeedContentConstants.contentList.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final content = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: FeedCard(
                        authorName: content.authorName,
                        authorAvatar: content.authorAvatar,
                        isVerified: content.isVerified,
                        publishedDate: content.publishedDate,
                        title: content.title,
                        description: content.description,
                        isLiked: content.isLiked,
                        likesCount: content.likesCount,
                        likedByUsername: content.likedByUsername,
                        commentsCount: content.commentsCount,
                        onMenuTap: () => controller.showFeedActionModal(index),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
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
