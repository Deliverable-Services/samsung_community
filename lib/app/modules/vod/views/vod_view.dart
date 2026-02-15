import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/common_loader.dart';
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
    if (_scrollController.positions.length != 1) return;
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
      child: RefreshIndicator(
        onRefresh: _controller.loadContent,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
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
                  _buildSearchBar(),
                  SizedBox(height: 20.h),
                  _buildFilters(),
                  SizedBox(height: 10.h),
                ]),
              ),
            ),
            _buildContentList(),
          ],
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
                controller: _controller.searchController,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontStyle: FontStyle.normal,
                  fontSize: 14.sp,
                  height: 24 / 14,
                  letterSpacing: 0,
                  color: AppColors.white.withOpacity(0.4),
                ),
                decoration: InputDecoration(
                  hintText: 'searchVodPodcasts'.tr,
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
              if (_controller.searchQuery.value.isNotEmpty) {
                return GestureDetector(
                  onTap: () {
                    _controller.searchController.clear();
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

      return Row(
        children: [
          for (int i = 0; i < filterItems.length; i++) ...[
            FilterTablet(
              text: filterItems[i].text,
              onTap: filterItems[i].onTap,
              isSelected: filterItems[i].isSelected,
            ),
            if (i < filterItems.length - 1) SizedBox(width: 10.w),
          ],
        ],
      );
    });
  }

  Widget _buildContentList() {
    return Obx(() {
      if (_controller.isLoadingContent.value &&
          _controller.contentList.isEmpty) {
        return const CommonSliverFillLoader();
      }

      final content = _controller.filteredContent;

      if (content.isEmpty && !_controller.isLoadingContent.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Text(
                'noContentAvailable'.tr,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14,
                  color: AppColors.textWhiteSecondary,
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
                  child: const CommonLoader(),
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
    final isPodcast = content.contentType == ContentType.podcast;
    final isVideo = content.contentType == ContentType.vod;
    final mediaUrl =
        content.mediaFileUrl ??
        (content.mediaFiles != null && content.mediaFiles!.isNotEmpty
            ? content.mediaFiles!.first
            : null);
    final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;
    return ContentCard1(
      imagePath: content.thumbnailUrl,
      title: content.title ?? '',
      description: content.description ?? '',
      showVideoPlayer: isVideo && hasMedia,
      showAudioPlayer: isPodcast && hasMedia,
      videoUrl: isVideo && hasMedia ? mediaUrl : null,
      audioUrl: isPodcast && hasMedia ? mediaUrl : null,
      thumbnailUrl: content.thumbnailUrl,
      thumbnailImage: content.thumbnailUrl,
      contentId: content.id,
      showSolutionButton: false,
    );
  }
}
