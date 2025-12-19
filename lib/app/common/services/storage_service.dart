import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

enum MediaType { image, video }

class StorageService {
  static Future<String?> uploadMedia({
    required File mediaFile,
    required String userId,
    required String bucketName,
    required MediaType mediaType,
    String? customFileName,
  }) async {
    try {
      final extension = _getFileExtension(mediaType);
      final fileName =
          customFileName ??
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '$userId/$fileName';

      final contentType = _getContentType(mediaType);

      await SupabaseService.client.storage
          .from(bucketName)
          .upload(
            filePath,
            mediaFile,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );

      final publicUrl = SupabaseService.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return null;
    }
  }

  static Future<String?> uploadProfilePicture({
    required File imageFile,
    required String userId,
    required String bucketName,
  }) async {
    return uploadMedia(
      mediaFile: imageFile,
      userId: userId,
      bucketName: bucketName,
      mediaType: MediaType.image,
    );
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

  static Future<XFile?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
      return video;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  static Future<XFile?> pickMedia({
    required MediaType mediaType,
    ImageSource source = ImageSource.gallery,
    Duration? maxVideoDuration,
  }) async {
    switch (mediaType) {
      case MediaType.image:
        return pickImage(source: source);
      case MediaType.video:
        return pickVideo(source: source, maxDuration: maxVideoDuration);
    }
  }

  static Future<void> deleteFile({
    required String filePath,
    required String bucketName,
  }) async {
    try {
      await SupabaseService.client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  static Future<void> deleteProfilePicture({
    required String filePath,
    required String bucketName,
  }) async {
    return deleteFile(filePath: filePath, bucketName: bucketName);
  }

  static String _getFileExtension(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return 'jpg';
      case MediaType.video:
        return 'mp4';
    }
  }

  static String _getContentType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return 'image/jpeg';
      case MediaType.video:
        return 'video/mp4';
    }
  }
}
