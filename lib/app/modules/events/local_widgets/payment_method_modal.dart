import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/back_button.dart';

class PaymentMethodModal extends StatelessWidget {
  final int userPoints;
  final int costPoints;
  final VoidCallback? onPayWithPoints;
  final VoidCallback onPayWithCreditCard;
  final bool isLoading;

  const PaymentMethodModal({
    super.key,
    required this.userPoints,
    required this.costPoints,
    this.onPayWithPoints,
    required this.onPayWithCreditCard,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Logic for disabling points button
    final bool canPayWithPoints = userPoints >= costPoints;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 32.h,
              child: Center(
                child: Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: CustomBackButton(
                onTap: isLoading
                    ? () {}
                    : () => Navigator.of(context, rootNavigator: true).pop(),
                rotation: 0,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        RichText(
          text: TextSpan(
            text: 'You currently have ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF6EA8FF),
              fontFamily: 'Samsung Sharp Sans',
            ),
            children: [
              TextSpan(
                text: '$userPoints points',
                style: const TextStyle(
                  color: Color(0xFF6EA8FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),

        AppButton(
          text: 'Pay with Points',
          iconPath: AppImages.pointsIcon,
          onTap: (canPayWithPoints && !isLoading) ? onPayWithPoints : () {},
          isEnabled: canPayWithPoints && !isLoading,
          isLoading: isLoading,
          width: double.infinity,
          height: 56.h,
        ),

        SizedBox(height: 16.h),

        AppButton(
          text: 'Pay with Credit Card',
          iconPath: AppImages.creditIcon,
          onTap: isLoading ? () {} : onPayWithCreditCard,
          isEnabled: !isLoading,
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
