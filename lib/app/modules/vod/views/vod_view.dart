import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/vod_controller.dart';

class VodView extends GetView<VodController> {
  const VodView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VodView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'VodView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
