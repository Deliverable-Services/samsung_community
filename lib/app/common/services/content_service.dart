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

      if (limit != null) {
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

