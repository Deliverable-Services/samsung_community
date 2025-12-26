import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_images.dart';

class PointTablet extends StatelessWidget {
  final String? text;
  final List<String>? texts;
  final VoidCallback? onTap;
  final double? spacing;

  const PointTablet({
    super.key,
    this.text,
    this.texts,
    this.onTap,
    this.spacing,
  }) : assert(
          (text != null && texts == null) || (text == null && texts != null),
          'Either text or texts must be provided, but not both',
        );

  List<String> _getTexts() {
    if (texts != null) return texts!;
    if (text != null) return [text!];
    return [];
  }

  Widget _buildSingleTablet(String tabletText) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(109.68.r),
          boxShadow: [
            // Multiple outer shadows
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.1),
              offset: Offset(0, 8.15.h),
              blurRadius: 18.21.r,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.09),
              offset: Offset(0, 33.07.h),
              blurRadius: 33.07.r,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              offset: Offset(0, 74.76.h),
              blurRadius: 45.05.r,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.01),
              offset: Offset(0, 132.74.h),
              blurRadius: 53.19.r,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.0),
              offset: Offset(0, 207.5.h),
              blurRadius: 57.99.r,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(109.68.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8.625896453857422,
              sigmaY: 8.625896453857422,
            ),
            child: Stack(
              children: [
                // Gradient border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(109.68.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(242, 242, 242, 0.2),
                        Color.fromRGBO(129, 129, 129, 0.2),
                        Color.fromRGBO(255, 255, 255, 0.2),
                      ],
                      stops: [0.0, 0.4142, 1.0],
                    ),
                  ),
                ),
                // Inner container with background gradient
                Padding(
                  padding: EdgeInsets.all(1.1.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(109.68.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(214, 214, 214, 0.2),
                          Color.fromRGBO(112, 112, 112, 0.2),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    child: Stack(
                      children: [
                        // Inset shadow effect using gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(109.68.r),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                const Color(0xFF000000).withOpacity(0.25),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3],
                            ),
                          ),
                        ),
                        // Content: Icon and Text
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Left sub container: Credit Icon
                            SvgPicture.asset(
                              AppImages.creditIcon,
                              width: 18.w,
                              height: 18.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 4.39.w),
                            // Right sub container: Label
                            Text(
                              tabletText,
                              style: TextStyle(
                                fontFamily: 'Samsung Sharp Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                height: 24 / 16,
                                letterSpacing: 0,
                                color: Colors.white,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabletTexts = _getTexts();
    if (tabletTexts.isEmpty) return const SizedBox.shrink();

    if (tabletTexts.length == 1) {
      return _buildSingleTablet(tabletTexts.first);
    }

    // Multiple tablets - display in rows with minimum space
    return Wrap(
      spacing: spacing ?? 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: tabletTexts
          .map((tabletText) => _buildSingleTablet(tabletText))
          .toList(),
    );
  }
}
