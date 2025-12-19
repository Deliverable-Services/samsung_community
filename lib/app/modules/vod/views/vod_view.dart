import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/helper_widgets/content_card.dart';
import '../../../data/helper_widgets/filter_component.dart';
import '../../../data/models/content_model.dart';
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
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildFilters(),
              SizedBox(height: 30.h),
              _buildContentList(),
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
      ],
    );
  }

  Widget _buildFilters() {
    return Obx(() {
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
    });
  }

  Widget _buildContentList() {
    return Obx(() {
      if (controller.isLoadingContent.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final content = controller.filteredContent;

      if (content.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: Text(
              'No content available',
              style: TextStyle(fontFamily: 'Samsung Sharp Sans', fontSize: 14),
            ),
          ),
        );
      }

      return Column(
        children: content.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: _buildContentCard(item),
          );
        }).toList(),
      );
    });
  }

  Widget _buildContentCard(ContentModel content) {
    final isVideo = content.contentType == ContentType.vod;
    final videoUrl =
        content.mediaFileUrl ??
        (content.mediaFiles != null && content.mediaFiles!.isNotEmpty
            ? content.mediaFiles!.first
            : null);
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;
    debugPrint('videoUrl: $videoUrl');

    return ContentCard(
      title: content.title ?? '',
      description: content.description ?? '',
      showVideoPlayer: isVideo && hasVideo,
      imagePath: null,
      videoUrl: videoUrl,
      thumbnailUrl: content.thumbnailUrl,
      thumbnailImage: content.thumbnailUrl,
    );
  }
}
