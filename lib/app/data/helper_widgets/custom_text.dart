import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class CustomText extends StatelessWidget {
  final String text;

  const CustomText(this.text, {super.key});

  @override
  SizedBox build(BuildContext context) {
    return SizedBox(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          color: AppColors.white,
          height: 22 / 22,
          fontFamily: 'Samsung Sharp Sans',
        ),
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }
}
