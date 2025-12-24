import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventsController extends GetxController {
  //TODO: Implement EventsController

  final count = 0.obs;

  TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
