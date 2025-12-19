import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/helper_widgets/content_card.dart';
import '../../../data/helper_widgets/filter_component.dart';
import '../../../data/models/content_model.dart';
import '../controllers/vod_controller.dart';

class VodView extends StatefulWidget {
  const VodView({super.key});

  @override
  State<VodView> createState() => _VodViewState();
}

class _VodViewState extends State<VodView> {
  late final ScrollController _scrollController;
  late final VodController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<VodController>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _controller.loadMoreContent();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 22.h,
              bottom: 22.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                SizedBox(height: 20.h),
                _buildFilters(),
                SizedBox(height: 30.h),
              ]),
            ),
          ),
          _buildContentList(),
        ],
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
      final index = _controller.selectedFilterIndex.value;
      final filterItems = [
        FilterItem(
          text: 'vodFilterAll'.tr,
          isSelected: index == 0,
          onTap: () => _controller.setFilter(0),
        ),
        FilterItem(
          text: 'vodFilterVod'.tr,
          isSelected: index == 1,
          onTap: () => _controller.setFilter(1),
        ),
        FilterItem(
          text: 'vodFilterPodcasts'.tr,
          isSelected: index == 2,
          onTap: () => _controller.setFilter(2),
        ),
      ];

      return FilterComponent(filterItems: filterItems);
    });
  }

  Widget _buildContentList() {
    return Obx(() {
      if (_controller.isLoadingContent.value &&
          _controller.contentList.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      final content = _controller.filteredContent;

      if (content.isEmpty && !_controller.isLoadingContent.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Text(
                'No content available',
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < content.length) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: _buildContentCard(content[index]),
                );
              }
              if (index == content.length && _controller.isLoadingMore.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return null;
            },
            childCount:
                content.length + (_controller.isLoadingMore.value ? 1 : 0),
          ),
        ),
      );
    });
  }

  Widget _buildContentCard(ContentModel content) {
    final isVideo = content.contentType != ContentType.feed;
    final videoUrl =
        content.mediaFileUrl ??
        (content.mediaFiles != null && content.mediaFiles!.isNotEmpty
            ? content.mediaFiles!.first
            : null);
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

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
