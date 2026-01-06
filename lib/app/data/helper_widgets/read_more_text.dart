import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final int maxLines;
  final String readMoreText;
  final String showLessText;
  final Color? linkColor;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  const ReadMoreText({
    super.key,
    required this.text,
    this.textStyle,
    this.maxLines = 5,
    this.readMoreText = 'readMore',
    this.showLessText = 'showLess',
    this.linkColor,
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontFamily: 'Samsung Sharp Sans',
      fontSize: 14.sp,
      height: 22 / 14,
      letterSpacing: 0,
      color: AppColors.textWhite,
    );

    final textStyle = widget.textStyle ?? defaultStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if text needs truncation based on available width
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        final needsTruncation = textPainter.didExceedMaxLines;

        if (!needsTruncation) {
          // Text is short enough, no need for read more
          return Text(widget.text, style: textStyle, textAlign: widget.textAlign);
        }

        return Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            Text(
              widget.text,
              style: textStyle,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              textAlign: widget.textAlign,
            ),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'showLess'.tr : 'readMore'.tr,
                style: textStyle.copyWith(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14.sp,
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
