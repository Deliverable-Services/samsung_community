import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/helper_widgets/alert_modal.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../data/models/store_product_model.dart';
import '../controllers/store_controller.dart';

class ShippingAddressModal extends StatefulWidget {
  final StoreProductModel product;
  final VoidCallback? onConfirm;

  const ShippingAddressModal({super.key, required this.product, this.onConfirm});

  static void show(BuildContext context, {required StoreProductModel product, VoidCallback? onConfirm}) {
    BottomSheetModal.show(
      context,
      content: ShippingAddressModal(product: product, onConfirm: onConfirm),
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

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${'city'.tr} ${'isRequired'.tr}';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'City must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'City must not exceed 50 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${'address'.tr} ${'isRequired'.tr}';
    }
    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return 'Address must be at least 5 characters';
    }
    if (trimmed.length > 200) {
      return 'Address must not exceed 200 characters';
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${'zipCode'.tr} ${'isRequired'.tr}';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'invalidZipCode'.tr;
    }
    if (trimmed.length != 6) {
      return 'Zip code must be exactly 6 digits';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${'contactPhoneNumber'.tr} ${'isRequired'.tr}';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Contact number must contain only digits';
    }
    if (trimmed.length > 10) {
      return 'Contact number must not exceed 10 digits';
    }
    return null;
  }

  bool _validateForm() {
    final cityError = _validateCity(_cityController.text);
    final addressError = _validateAddress(_addressController.text);
    final zipCodeError = _validateZipCode(_zipCodeController.text);
    final phoneError = _validatePhone(_phoneController.text);

    if (cityError != null) {
      CommonSnackbar.error(cityError);
      return false;
    }
    if (addressError != null) {
      CommonSnackbar.error(addressError);
      return false;
    }
    if (zipCodeError != null) {
      CommonSnackbar.error(zipCodeError);
      return false;
    }
    if (phoneError != null) {
      CommonSnackbar.error(phoneError);
      return false;
    }
    return true;
  }

  Future<void> _handleConfirmation(BuildContext context) async {
    if (!_validateForm()) {
      return;
    }

    final controller = Get.find<StoreController>();
    
    final success = await controller.createOrder(
      product: widget.product,
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!success) {
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
            validator: _validateCity,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'address'.tr,
            controller: _addressController,
            placeholder: 'type'.tr,
            width: double.infinity,
            validator: _validateAddress,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'zipCode'.tr,
            controller: _zipCodeController,
            keyboardType: TextInputType.number,
            placeholder: 'type'.tr,
            width: double.infinity,
            validator: _validateZipCode,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'contactPhoneNumber'.tr,
            controller: _phoneController,
            keyboardType: TextInputType.number,
            placeholder: 'type'.tr,
            width: double.infinity,
            validator: _validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          SizedBox(height: 30.h),
          Obx(() {
            final controller = Get.find<StoreController>();
            return AppButton(
              onTap: controller.isCreatingOrder.value
                  ? null
                  : () => _handleConfirmation(context),
              text: controller.isCreatingOrder.value
                  ? 'Processing...'
                  : 'confirmation'.tr,
              width: double.infinity,
              isEnabled: !controller.isCreatingOrder.value,
            );
          }),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
