import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';

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
  bool _isExpanded = false;
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

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_needsReadMore && !_isExpanded) {
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
                    maxLines: _isExpanded ? null : 5,
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_needsReadMore) ...[
              SizedBox(height: 5.h),
              GestureDetector(
                onTap: _toggleExpanded,
                child: Text(
                  _isExpanded ? 'showLess'.tr : 'readMore'.tr,
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
