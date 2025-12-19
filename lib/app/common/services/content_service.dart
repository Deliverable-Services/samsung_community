
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/content_model.dart';
import 'supabase_service.dart';

class ContentService {
  Future<Result<List<ContentModel>>> getContent({
    ContentType? contentType,
    bool? isPublished,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = SupabaseService.client.from('content').select();

      if (contentType != null) {
        query = query.eq('content_type', contentType.toJson());
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      var transformQuery = query.order('created_at', ascending: false);

      if (offset != null) {
        transformQuery = transformQuery.range(offset, offset + (limit ?? 20) - 1);
      } else if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }

      final response = await transformQuery;

      final contentList = (response as List)
          .map((json) => ContentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(contentList);
    } catch (e) {
      debugPrint('Error in getContent: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>>> addContent({
    required Map<String, dynamic> content,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('content')
          .insert(content) // ✅ DO NOT jsonEncode
          .select()
          .maybeSingle(); // ✅ Safe

      if (response == null) {
        return Failure('Content was not inserted. Check RLS policies.');
      }

      return Success(response);
    } catch (e) {
      debugPrint('Error in addContent: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<void>> deleteContent(String contentId) async {
    try {
      await SupabaseService.client
          .from('content')
          .delete()
          .eq('id', contentId);

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }


  Future<Result<void>> updateContent(
      String contentId, {
        String? title,
        String? description,
        bool? isPublished,
        bool? isFeatured,
        List? externalSharePlatforms,
      }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (isPublished != null) updates['is_published'] = isPublished;
      if (isFeatured != null) updates['is_featured'] = isFeatured;
      if (externalSharePlatforms != null) updates['external_share_platforms'] = externalSharePlatforms;

      if (updates.isEmpty) {
        return const Success(null); // nothing to update
      }

      await SupabaseService.client
          .from('content')
          .update(updates)
          .eq('id', contentId);

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }




  Future<Result<ContentModel?>> getContentById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('content')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      final content = ContentModel.fromJson(response);
      return Success(content);
    } catch (e) {
      debugPrint('Error in getContentById: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<void>> incrementViewCount(String contentId) async {
    try {
      final currentContent = await getContentById(contentId);
      if (currentContent.isFailure) {
        return Failure(currentContent.errorOrNull ?? 'failedToCheckUser'.tr);
      }

      final content = currentContent.dataOrNull;
      if (content == null) {
        return const Failure('Content not found');
      }

      await SupabaseService.client
          .from('content')
          .update({'view_count': content.viewCount + 1})
          .eq('id', contentId);

      return const Success(null);
    } catch (e) {
      debugPrint('Error in incrementViewCount: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
