import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventEmailController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxString email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    email.value = emailController.text.trim();
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.value);
  }

  @override
  void onClose() {
    emailController.removeListener(_onEmailChanged);
    emailController.dispose();
    super.onClose();
  }
}

