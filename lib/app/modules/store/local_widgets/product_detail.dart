import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/event_tablet.dart';
import '../../../data/helper_widgets/point_tablet.dart';
import '../../../data/helper_widgets/read_more_text.dart';
import '../../../data/helper_widgets/video_player/video_player_widget.dart';

class ProductDetail extends StatelessWidget {
  final List<String>? topTablets;
  final String title;
  final String? description;
  final List<String>? middleTablets;
  final String? mediaUrl;
  final bool isVideo;
  final String? bottomButtonText;
  final VoidCallback? bottomButtonOnTap;
  final bool isButtonEnabled;
  final String? tag;

  const ProductDetail({
    super.key,
    this.topTablets,
    required this.title,
    this.description,
    this.middleTablets,
    this.mediaUrl,
    this.isVideo = false,
    this.bottomButtonText,
    this.bottomButtonOnTap,
    this.isButtonEnabled = true,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top tablets
                    if (topTablets != null && topTablets!.isNotEmpty) ...[
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: topTablets!
                            .map(
                              (text) => IntrinsicWidth(
                                child: EventTablet(text: text),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.white,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    SizedBox(height: 8.h),
                    // Description with read more
                    if (description != null && description!.isNotEmpty)
                      ReadMoreText(text: description!, maxLines: 5),
                    // Middle tablets (PointTablet)
                    if (middleTablets != null && middleTablets!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      PointTablet(texts: middleTablets),
                    ],
                    SizedBox(height: 20.h),
                    // Media (Video or Image)
                    if (mediaUrl != null && mediaUrl!.isNotEmpty)
                      if (isVideo)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: VideoPlayerWidget(
                            videoUrl: mediaUrl,
                            tag:
                                tag ??
                                'product_detail_${DateTime.now().millisecondsSinceEpoch}',
                          ),
                        )
                      else if (mediaUrl!.startsWith('http'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: CachedNetworkImage(
                            imageUrl: mediaUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200.h,
                              color: AppColors.backgroundDark,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Container(
                                height: 200.h,
                                color: AppColors.backgroundDark,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.textWhiteOpacity60,
                                    size: 48.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.asset(
                            mediaUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200.h,
                                color: AppColors.backgroundDark,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: AppColors.textWhiteOpacity60,
                                    size: 48.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ),
            // Sticky button at bottom
            if (bottomButtonText != null && bottomButtonOnTap != null)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h, top: 24.h),
                child: AppButton(
                  onTap: isButtonEnabled ? bottomButtonOnTap : () {},
                  text: bottomButtonText!,
                  width: double.infinity,
                  isEnabled: isButtonEnabled,
                ),
              ),
          ],
        );
      },
    );
  }
}
