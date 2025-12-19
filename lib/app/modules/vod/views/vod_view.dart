import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/vod_content.dart';
import '../../../data/helper_widgets/content_card.dart';
import '../../../data/helper_widgets/filter_component.dart';

import '../controllers/vod_controller.dart';

class VodView extends GetView<VodController> {
  const VodView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              Text(
                'vodPodcastsTitle'.tr,
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
                  'vodPodcastsDescription'.tr,
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
              SizedBox(height: 20.h),
              Obx(() {
                final index = controller.selectedFilterIndex.value;
                final filterItems = [
                  FilterItem(
                    text: 'vodFilterAll'.tr,
                    isSelected: index == 0,
                    onTap: () => controller.setFilter(0),
                  ),
                  FilterItem(
                    text: 'vodFilterVod'.tr,
                    isSelected: index == 1,
                    onTap: () => controller.setFilter(1),
                  ),
                  FilterItem(
                    text: 'vodFilterPodcasts'.tr,
                    isSelected: index == 2,
                    onTap: () => controller.setFilter(2),
                  ),
                ];

                return FilterComponent(filterItems: filterItems);
              }),
              SizedBox(height: 30.h),
              ...VodContentConstants.contentList.map((content) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: ContentCard(
                    title: content.title.tr,
                    description: content.description.tr,
                    showVideoPlayer: content.showVideoPlayer,
                    imagePath: content.imagePath,
                    videoUrl: content.videoUrl,
                    thumbnailUrl: content.thumbnailUrl,
                    thumbnailImage: content.thumbnailImage,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
