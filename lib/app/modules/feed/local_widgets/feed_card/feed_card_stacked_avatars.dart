import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/constants/app_images.dart';

class FeedCardStackedAvatars extends StatelessWidget {
  const FeedCardStackedAvatars({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: Stack(
        children: [
          _AvatarItem(),
          Positioned(left: 12.w, child: _AvatarItem()),
          Positioned(left: 24.w, child: _AvatarItem()),
        ],
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  const _AvatarItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.w,
      height: 18.h,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Image.asset(
        AppImages.avatar,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}

