import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/personal_details_controller.dart';

class PersonalDetailsView extends GetView<PersonalDetailsController> {
  const PersonalDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PersonalDetailsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PersonalDetailsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
