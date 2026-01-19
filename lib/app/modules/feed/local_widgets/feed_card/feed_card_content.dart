import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/helper_widgets/close_button.dart';

class FeedCardContent extends StatefulWidget {
  final String title;
  final String description;

  const FeedCardContent({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<FeedCardContent> createState() => _FeedCardContentState();
}

class _FeedCardContentState extends State<FeedCardContent> {
  bool _needsReadMore = false;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsReadMore();
    });
  }

  void _checkIfNeedsReadMore() {
    final RenderBox? renderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.description,
        style: TextStyle(
          fontFamily: 'Samsung Sharp Sans',
          fontSize: 14.sp,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      maxLines: 5,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: renderBox.constraints.maxWidth);
    final exceedsMaxLines = textPainter.didExceedMaxLines;

    if (mounted) {
      setState(() {
        _needsReadMore = exceedsMaxLines;
      });
    }
  }

  void _showFullContentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayBackground,
      useRootNavigator: true,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final maxHeight = mediaQuery.size.height * 0.85;

        return LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                // Sheet will grow with content up to 85% of screen height
                maxHeight: maxHeight,
              ),
              child: SafeArea(
                top: true,
                bottom: false,
                minimum: EdgeInsets.only(top: 20.h),
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from closing when tapping inside
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.overlayContainerBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -6.h),
                          blurRadius: 50.r,
                          spreadRadius: 0,
                          color: AppColors.overlayContainerShadow,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 20.h,
                        left: 20.w,
                        right: 20.w,
                        bottom: 20.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomCloseButton(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                          SizedBox(height: 10.h),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontFamily: 'Samsung Sharp Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.sp,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    widget.description,
                                    style: TextStyle(
                                      fontFamily: 'Samsung Sharp Sans',
                                      fontSize: 14.sp,
                                      color: AppColors.textWhiteOpacity70,
                                      height: 1.5,
                                      fontWeight: FontWeight.w700,
                                    ),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_needsReadMore) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: widget.description,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            maxLines: 5,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: constraints.maxWidth);
          if (textPainter.didExceedMaxLines && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _needsReadMore = true;
                });
              }
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textWhite,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    key: _textKey,
                    widget.description,
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontSize: 14.sp,
                      color: AppColors.textWhiteOpacity70,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_needsReadMore) ...[
              SizedBox(height: 5.h),
              GestureDetector(
                onTap: _showFullContentModal,
                child: Text(
                  'readMore'.tr,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontSize: 14.sp,
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
