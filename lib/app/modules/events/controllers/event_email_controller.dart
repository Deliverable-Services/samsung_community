import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventEmailController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxString email = ''.obs;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    if (!_isDisposed) {
      email.value = emailController.text.trim();
    }
  }

  bool get isValidEmail {
    if (_isDisposed) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.value);
  }

  @override
  void onClose() {
    _isDisposed = true;
    emailController.removeListener(_onEmailChanged);
    // Dispose controller immediately since we're already marked as disposed
    // The widget tree should not be using it anymore at this point
    emailController.dispose();
    super.onClose();
  }
}

