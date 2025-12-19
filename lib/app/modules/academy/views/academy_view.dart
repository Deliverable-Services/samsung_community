import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/academy_controller.dart';

class AcademyView extends GetView<AcademyController> {
  const AcademyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AcademyView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AcademyView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
