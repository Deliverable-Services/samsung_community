import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class StorageService {
  static const String profilePicturesBucket = 'profile_pictures';

  static Future<String?> uploadProfilePicture({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      await SupabaseService.client.storage
          .from(profilePicturesBucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = SupabaseService.client.storage
          .from(profilePicturesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }

  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<void> deleteProfilePicture(String filePath) async {
    try {
      await SupabaseService.client.storage.from(profilePicturesBucket).remove([
        filePath,
      ]);
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
    }
  }
}
