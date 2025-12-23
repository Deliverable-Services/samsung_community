import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/chat_screen_controller.dart';
import '../local_widgets/chat_header.dart';
import '../local_widgets/chat_profile_section.dart';
import '../local_widgets/chat_messages_list.dart';
import '../local_widgets/chat_input_bar.dart';

class ChatScreenView extends GetView<ChatScreenController> {
  const ChatScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ChatProfileSection(controller: controller),
                    ChatMessagesList(controller: controller),
                  ],
                ),
              ),
            ),
            ChatInputBar(controller: controller),
          ],
        ),
      ),
    );
  }
}
