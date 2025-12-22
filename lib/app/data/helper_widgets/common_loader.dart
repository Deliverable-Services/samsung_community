import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class CommonLoader extends StatelessWidget {
  final Color? color;
  final double? size;

  const CommonLoader({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.linkBlue,
          ),
        ),
      ),
    );
  }
}

class CommonSliverLoader extends StatelessWidget {
  final Color? color;
  final double? size;
  final EdgeInsets? padding;

  const CommonSliverLoader({
    super.key,
    this.color,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            CommonLoader(color: color, size: size),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class CommonSliverFillLoader extends StatelessWidget {
  final Color? color;
  final double? size;

  const CommonSliverFillLoader({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: CommonLoader(color: color, size: size),
    );
  }
}

