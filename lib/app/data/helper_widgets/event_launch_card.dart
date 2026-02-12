import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'event_tablet.dart';

class EventLabel {
  final String? text;
  final Widget? widget;
  final VoidCallback? onTap;
  final EdgeInsets? extraPadding;

  const EventLabel({this.text, this.widget, this.onTap, this.extraPadding})
    : assert(
        (text != null && widget == null) || (text == null && widget != null),
        'Either text or widget must be provided, but not both',
      );
}

class EventLaunchCard extends StatelessWidget {
  final String imagePath;
  String? imagePathNetwork;
  final String title;
  final String description;
  final String? buttonText;
  final String? text;
  final bool showButton;
  final VoidCallback? onButtonTap;
  final bool exclusiveEvent;
  final EdgeInsets? extraPaddingForButton;
  final List<EventLabel>? labels;

  EventLaunchCard({
    super.key,
    required this.imagePath,
    this.imagePathNetwork,
    required this.title,
    required this.description,
    this.buttonText,
    this.text,
    this.showButton = false,
    this.onButtonTap,
    this.exclusiveEvent = true,
    this.extraPaddingForButton,
    this.labels,
  });
  @override
  Widget build(BuildContext context) {
    debugPrint(imagePathNetwork ?? '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          (imagePathNetwork != null && imagePathNetwork!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: imagePathNetwork!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 180.h,
                    width: double.infinity,
                    color: AppColors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180.h,
                    );
                  },
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
          if (showButton && text != null && exclusiveEvent)
            Positioned(
              top: 16.h,
              right: 16.w,
              child: EventTablet(
                text: text!,
                onTap: onButtonTap,
                extraPadding: extraPaddingForButton,
              ),
            ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (labels != null && labels!.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: labels!.map((label) {
                          final chip = (label.text != null)
                              ? IntrinsicWidth(
                                  child: EventTablet(
                                    text: label.text!,
                                    onTap: label.onTap,
                                    extraPadding: label.extraPadding,
                                  ),
                                )
                              : (label.widget != null)
                              ? IntrinsicWidth(
                                  child: EventTablet(
                                    widget: label.widget!,
                                    onTap: label.onTap,
                                    extraPadding: label.extraPadding,
                                  ),
                                )
                              : const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: chip,
                          );
                        }).toList(),
                      ),
                    ),
                  if (labels != null && labels!.isNotEmpty)
                    SizedBox(height: 8.h),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: 300.w,
                    child: Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontSize: 14.sp,
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: AppColors.white,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (exclusiveEvent)
                    GestureDetector(
                      onTap: onButtonTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFBEBEBE),
                                        Color(0xFFFFFFFF),
                                      ],
                                      stops: [0.0101, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    buttonText ?? "eventDetailsRegistration".tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      fontFamily: 'Samsung Sharp Sans',
                                      height: 1.0,
                                      letterSpacing: 0,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                    textScaler: const TextScaler.linear(1.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Container(
                            width: 16.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.09.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF000000,
                                  ).withOpacity(0.1),
                                  offset: Offset(0, 2.08.h),
                                  blurRadius: 4.65.r,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.09.r),
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
                                Padding(
                                  padding: EdgeInsets.all(0.w),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        5.09.r,
                                      ),
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
                                    padding: EdgeInsets.fromLTRB(
                                      0.w,
                                      2.5.h,
                                      0.w,
                                      2.5.h,
                                    ),
                                    child: Image.asset(
                                      AppImages.arrowIcon,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.contain,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (text != null)
                    IntrinsicWidth(
                      child: EventTablet(
                        text: text!,
                        onTap: onButtonTap,
                        extraPadding: extraPaddingForButton,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AllEventLaunchCard extends StatelessWidget {
  final String imagePath;
  String? imagePathNetwork;
  final String title;
  final String description;
  final String? buttonText;
  final List<EventLabel>? labels;
  final bool exclusiveEvent;
  final VoidCallback? onButtonTap;

  AllEventLaunchCard({
    super.key,
    required this.imagePath,
    this.imagePathNetwork,
    this.exclusiveEvent = false,
    required this.title,
    required this.description,
    this.buttonText,
    this.labels,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: AspectRatio(
        aspectRatio: 16 / 9, // Standard card aspect ratio
        child: Stack(
          children: [
            // Background image - takes full height
            (imagePathNetwork != null && imagePathNetwork!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: imagePathNetwork!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.black.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
            // Labels at the top
            if (labels != null && labels!.isNotEmpty)
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: labels!.map((label) {
                      final chip = (label.text != null)
                          ? IntrinsicWidth(
                              child: EventTablet(
                                text: label.text!,
                                onTap: label.onTap,
                                extraPadding: label.extraPadding,
                              ),
                            )
                          : (label.widget != null)
                          ? IntrinsicWidth(
                              child: EventTablet(
                                widget: label.widget!,
                                onTap: label.onTap,
                                extraPadding: label.extraPadding,
                              ),
                            )
                          : const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: chip,
                      );
                    }).toList(),
                  ),
                ),
              ),
            // Gradient overlay at the bottom for text visibility
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                height: 150.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Content at the bottom
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        fontFamily: 'Samsung Sharp Sans',
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: AppColors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1.h),
                            blurRadius: 3.r,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          Shadow(
                            offset: Offset(0, 2.h),
                            blurRadius: 6.r,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: 300.w,
                      child: Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontSize: 14.sp,
                          height: 22 / 14,
                          letterSpacing: 0,
                          color: AppColors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1.h),
                              blurRadius: 3.r,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            Shadow(
                              offset: Offset(0, 2.h),
                              blurRadius: 6.r,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                        textScaler: const TextScaler.linear(1.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (exclusiveEvent)
                      GestureDetector(
                        onTap: onButtonTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      // 181.18deg gradient: almost vertical (180deg), slightly rotated
                                      // Using Alignment to represent the direction
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFBEBEBE), // #BEBEBE
                                          Color(0xFFFFFFFF), // #FFFFFF
                                        ],
                                        stops: [
                                          0.0101,
                                          1.0,
                                        ], // Clamp 119.84% to 1.0
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      buttonText ??
                                          "eventDetailsRegistration".tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        fontFamily: 'Samsung Sharp Sans',
                                        height: 1.0,
                                        letterSpacing: 0,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1.h),
                                            blurRadius: 3.r,
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          Shadow(
                                            offset: Offset(0, 2.h),
                                            blurRadius: 6.r,
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Container(
                              width: 16.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.09.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF000000,
                                    ).withOpacity(0.1),
                                    offset: Offset(0, 2.08.h),
                                    blurRadius: 4.65.r,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Gradient border
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        5.09.r,
                                      ),
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
                                    padding: EdgeInsets.all(0.w),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          5.09.r,
                                        ),
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
                                      padding: EdgeInsets.fromLTRB(
                                        0.w,
                                        2.5.h,
                                        0.w,
                                        2.5.h,
                                      ),
                                      child: Image.asset(
                                        AppImages.arrowIcon,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
