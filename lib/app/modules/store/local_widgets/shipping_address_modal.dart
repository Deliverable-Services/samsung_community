import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/helper_widgets/alert_modal.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../data/constants/app_images.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShippingAddressModal extends StatefulWidget {
  final VoidCallback? onConfirm;

  const ShippingAddressModal({super.key, this.onConfirm});

  static void show(BuildContext context, {VoidCallback? onConfirm}) {
    BottomSheetModal.show(
      context,
      content: ShippingAddressModal(onConfirm: onConfirm),
      buttonType: BottomSheetButtonType.close,
      isScrollControlled: true,
    );
  }

  @override
  State<ShippingAddressModal> createState() => _ShippingAddressModalState();
}

class _ShippingAddressModalState extends State<ShippingAddressModal> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_cityController.text.trim().isEmpty) {
      CommonSnackbar.error('${'city'.tr} ${'isRequired'.tr}');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      CommonSnackbar.error('${'address'.tr} ${'isRequired'.tr}');
      return false;
    }
    if (_zipCodeController.text.trim().isEmpty) {
      CommonSnackbar.error('${'zipCode'.tr} ${'isRequired'.tr}');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      CommonSnackbar.error('${'contactPhoneNumber'.tr} ${'isRequired'.tr}');
      return false;
    }
    return true;
  }

  void _handleConfirmation(BuildContext context) {
    if (!_validateForm()) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();
    widget.onConfirm?.call();

    AlertModal.show(
      context,
      icon: SizedBox(
        width: 50.w,
        height: 50.h,
        child: SvgPicture.asset(
          AppImages.verifiedIcon,
          width: 50.w,
          height: 50.h,
          fit: BoxFit.fitHeight,
        ),
      ),
      title: 'orderCompletedSuccessfully'.tr,
      description: 'courierContactMessage'.tr,
      buttonText: 'close'.tr,
      isScrollControlled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'shippingAddress'.tr,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              height: 24 / 18,
              letterSpacing: 0,
              color: AppColors.white,
            ),
            textScaler: const TextScaler.linear(1.0),
          ),
          SizedBox(height: 24.h),
          CustomTextField(
            label: 'city'.tr,
            controller: _cityController,
            placeholder: 'type'.tr,
            width: double.infinity,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'address'.tr,
            controller: _addressController,
            placeholder: 'type'.tr,
            width: double.infinity,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'zipCode'.tr,
            controller: _zipCodeController,
            keyboardType: TextInputType.number,
            placeholder: 'type'.tr,
            width: double.infinity,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'contactPhoneNumber'.tr,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            placeholder: 'type'.tr,
            width: double.infinity,
          ),
          SizedBox(height: 30.h),
          AppButton(
            onTap: () => _handleConfirmation(context),
            text: 'confirmation'.tr,
            width: double.infinity,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
