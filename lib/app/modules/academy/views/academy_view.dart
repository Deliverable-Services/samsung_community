import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../../../data/helper_widgets/content_card.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
import '../../../data/helper_widgets/filter_component.dart';
import '../../../data/models/academy_content_model.dart';
import '../../../data/models/weekly_riddle_model.dart';
import '../controllers/academy_controller.dart';
import 'assignment_card.dart';

class AcademyView extends GetView<AcademyController> {
  const AcademyView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: RefreshIndicator(
        onRefresh: controller.loadContent,
        child: CustomScrollView(
          controller: controller.scrollController,
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
          'academyTitle'.tr,
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
            'academyDescription'.tr,
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
                  hintText: 'searchForInspiration'.tr,
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

  Widget _buildFilters() {
    return Obx(() {
      final index = controller.selectedFilterIndex.value;
      final filterItems = [
        FilterItem(
          text: 'academyAll'.tr,
          isSelected: index == 0,
          onTap: () => controller.setFilter(0),
        ),
        FilterItem(
          text: 'academyVideos'.tr,
          isSelected: index == 1,
          onTap: () => controller.setFilter(1),
        ),
        // FilterItem(
        //   text: 'academyReels'.tr,
        //   isSelected: index == 2,
        //   onTap: () => controller.setFilter(2),
        // ),
        FilterItem(
          text: 'academyZoomWorkshops'.tr,
          isSelected: index == 3,
          onTap: () => controller.setFilter(3),
        ),
        FilterItem(
          text: 'academyAssignments'.tr,
          isSelected: index == 4,
          onTap: () => controller.setFilter(4),
        ),
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
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
        ),
      );
    });
  }

  Widget _buildContentList() {
    return Obx(() {
      if (controller.isLoadingContent.value && controller.contentList.isEmpty) {
        return const CommonSliverFillLoader();
      }

      final content = controller.filteredContent;

      if (content.isEmpty && !controller.isLoadingContent.value) {
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
                return _buildContentCard(content[index]);
              }
              if (index == content.length && controller.isLoadingMore.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const CommonLoader(),
                );
              }
              return null;
            },
            childCount:
                content.length + (controller.isLoadingMore.value ? 1 : 0),
          ),
        ),
      );
    });
  }

  Widget _buildContentCard(AcademyContentModel content) {
    final isReel = content.fileType == AcademyFileType.reel;
    final isVideo = content.fileType == AcademyFileType.video;
    final isAssignment = content.fileType == AcademyFileType.assignment;
    final isZoomWorkshop = content.fileType == AcademyFileType.zoomWorkshop;
    final mediaUrl = content.mediaFileUrl;
    final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;
    bool userIdMatched =
        content.submissionUserIds?.contains(SupabaseService.currentUser?.id) ??
        false;

    if (userIdMatched) {
      return SizedBox();
    }
    if (isZoomWorkshop) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Container(
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
            title: content.title,
            description: content.description ?? '',
            text: 'homeMoreDetails'.tr,
            showButton: true,
            onButtonTap: () => controller.clickOnMoreDetails(content: content),
            exclusiveEvent: false,
            extraPaddingForButton: EdgeInsets.symmetric(horizontal: 16.w),
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
                      "${'homePoints'.tr} ${content.pointsToEarn}",
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
                text: DateFormat(
                  'dd.MM.yyyy',
                ).format(DateTime.parse("${content.createdAt}")),
                onTap: () {
                  // TODO: Handle button tap
                },
              ),
            ],
          ),
        ),
      );
    } else if (isAssignment) {
      final isAudio = content.taskType?.toUpperCase() == 'Audio'.toUpperCase();
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: AssignmentCard(
          type: AssignmentCardType.assignment,
          title: content.title,
          description: content.description ?? '',
          showAudioPlayer: isAssignment && hasMedia,
          audioUrl: isAssignment && hasMedia ? mediaUrl : null,
          contentId: content.academyContentId,
          pointsToEarn: content.pointsToEarn,
          isAudio: isAudio,
          onButtonTap: () => controller.clickOnButtonTap(content: content),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: ContentCard1(
          showTopIcon: true,
          imagePath: content.mediaFileUrl,
          title: content.title,
          description: content.description ?? '',
          showVideoPlayer: isVideo && hasMedia,
          showAudioPlayer: isAssignment && hasMedia,
          videoUrl: isVideo && hasMedia ? mediaUrl : null,
          audioUrl: isAssignment && hasMedia ? mediaUrl : null,
          thumbnailUrl: content.mediaFileUrl,
          thumbnailImage: content.mediaFileUrl,
          contentId: content.academyContentId,
        ),
      );
    }
  }
}
