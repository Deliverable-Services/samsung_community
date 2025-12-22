import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'feed_card_avatar.dart';
import 'feed_card_author_info.dart';
import 'feed_card_menu_button.dart';

class FeedCardHeader extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final bool isVerified;
  final String publishedDate;
  final VoidCallback? onMenuTap;
  final VoidCallback? onAvatarTap;

  const FeedCardHeader({
    super.key,
    required this.authorName,
    this.authorAvatar,
    this.isVerified = false,
    required this.publishedDate,
    this.onMenuTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FeedCardAvatar(
          authorAvatar: authorAvatar,
          onTap: onAvatarTap,
        ),
        SizedBox(width: 12.w),
        FeedCardAuthorInfo(
          authorName: authorName,
          isVerified: isVerified,
          publishedDate: publishedDate,
        ),
        FeedCardMenuButton(onMenuTap: onMenuTap),
      ],
    );
  }
}

