import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/constants/app_images.dart';

class FeedCardAvatar extends StatelessWidget {
  final String? authorAvatar;
  final VoidCallback? onTap;

  const FeedCardAvatar({
    super.key,
    this.authorAvatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
      width: 57.h,
      height: 57.h,
      child: authorAvatar?.isNotEmpty == true
          ? CachedNetworkImage(
              imageUrl: authorAvatar!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fitHeight,
              errorWidget: (_, __, ___) => Image.asset(
                AppImages.avatar,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fitHeight,
              ),
            )
          : Image.asset(
              AppImages.avatar,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fitHeight,
              ),
            ),
    );
  }
}

