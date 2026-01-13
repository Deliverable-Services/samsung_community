import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../../../data/helper_widgets/create_post_button.dart';
import '../../../data/helper_widgets/filter_component.dart';
import '../../../routes/app_pages.dart';
import '../controllers/feed_controller.dart';
import '../local_widgets/feed_card/feed_card.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late final ScrollController _scrollController;
  late final FeedController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FeedController>();
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
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _controller.loadContent,
          child: Obx(() {
            return _controller.isLoading.value
                ? const CommonLoader()
                : CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    cacheExtent: 500,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 12.h,
                          bottom: 22.h,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            SearchWidget(
                              placeholder: 'searchForInspiration'.tr,
                              controller: _controller.searchController,
                              onChanged: _controller.onSearchChanged,
                            ),
                            SizedBox(height: 20.h),
                            if (_controller.filteredContentList.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40.h),
                                  child: Text(
                                    'noContentAvailable'.tr,
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >=
                                  _controller.filteredContentList.length) {
                                return null;
                              }

                              final content =
                                  _controller.filteredContentList[index];
                              final likedUsers = _controller.getLikedByUsers(
                                content.id,
                              );

                              return RepaintBoundary(
                                key: ValueKey('feed_card_${content.id}'),
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20.h),
                                  child: FeedCard(
                                    contentId: content.id,
                                    authorName:
                                        content.userModel?.fullName ?? '',
                                    authorAvatar:
                                        content.userModel?.profilePictureUrl ??
                                        '',
                                    isVerified: content.isPublished,
                                    publishedDate: DateFormat(
                                      'dd/MM/yy',
                                    ).format(content.createdAt),
                                    title: content.title ?? '',
                                    description: content.description ?? '',
                                    mediaUrl:
                                        content.mediaFileUrl ??
                                        (content.mediaFiles != null &&
                                                content.mediaFiles!.isNotEmpty
                                            ? content.mediaFiles!.first
                                            : null),
                                    thumbnailUrl: content.thumbnailUrl,
                                    isLiked: _controller.isLiked(content.id),
                                    likesCount: content.likesCount,
                                    likedByUsers: likedUsers.isNotEmpty
                                        ? likedUsers
                                        : null,
                                    commentsCount: content.commentsCount,
                                    onLike: () =>
                                        _controller.toggleLike(content.id),
                                    onComment: () => _controller
                                        .showCommentsModal(content.id),
                                    onViewComments: () => _controller
                                        .showCommentsModal(content.id),
                                    onMenuTap: () => _controller
                                        .showFeedActionModal(content.id),
                                    onAddComment: (contentId, commentText) =>
                                        _controller.addComment(
                                          contentId,
                                          commentText,
                                        ),
                                    onAvatarTap: () {
                                      final userId = content.userId;
                                      if (userId.isEmpty) return;
                                      final currentId =
                                          SupabaseService.currentUser?.id;
                                      if (currentId != null &&
                                          currentId == userId) {
                                        Get.toNamed(Routes.PROFILE);
                                      } else {
                                        Get.toNamed(
                                          Routes.USER_PROFILE,
                                          parameters: {'userId': userId},
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount:
                                _controller.filteredContentList.length +
                                (_controller.isLoadingMore.value ? 1 : 0),
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries:
                                false, // We're adding RepaintBoundary manually
                          ),
                        ),
                      ),
                      if (_controller.isLoadingMore.value)
                        SliverPadding(
                          padding: EdgeInsets.all(16.w),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: const CommonLoader(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
          }),
        ),
        CreatePostButton(
          onSuccess: () {
            _controller.loadContent();
          },
          onFailure: () {},
        ),
      ],
    );
  }
}
