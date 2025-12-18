import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/events_controller.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'EventsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
