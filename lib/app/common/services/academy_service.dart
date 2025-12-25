import 'package:flutter/foundation.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/academy_content_model.dart';
import 'supabase_service.dart';

class AcademyService {
  Future<Result<List<AcademyContentModel>>> getAcademy({
    AcademyFileType? contentType,
    List<AcademyFileType>? allowedAcademyTypes,
    bool? isPublished,
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    try {
      var query = SupabaseService.client
          .from('academy_content')
          .select()
          .isFilter('deleted_at', null);
      print('contentType::::::::::${contentType}');
      if (contentType != null) {
        query = query.eq('file_type', contentType.toJson());
      } else if (allowedAcademyTypes != null &&
          allowedAcademyTypes.isNotEmpty) {
        if (allowedAcademyTypes.length == 1) {
          query = query.eq('file_type', allowedAcademyTypes.first.toJson());
        } else {
          final firstType = allowedAcademyTypes.first.toJson();
          final secondType = allowedAcademyTypes.last.toJson();
          query = query.or('file_type.eq.$firstType,file_type.eq.$secondType');
        }
      }

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final searchTerm = '%${searchQuery.trim()}%';
        query = query.ilike('title', searchTerm);
      }

      var transformQuery = query.order('created_at', ascending: false);

      if (offset != null) {
        transformQuery = transformQuery.range(
          offset,
          offset + (limit ?? 20) - 1,
        );
      } else if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }

      final response = await transformQuery;
      print('response:::::::::::${response}');

      final contentList = (response as List)
          .map(
            (json) =>
                AcademyContentModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Success(contentList);
    } catch (e) {
      debugPrint('Error in getAcademy: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>>> addAcademy({
    required Map<String, dynamic> content,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('academy_content')
          .insert(content) // ✅ DO NOT jsonEncode
          .select()
          .maybeSingle(); // ✅ Safe

      if (response == null) {
        return Failure('Academy was not inserted. Check RLS policies.');
      }

      return Success(response);
    } catch (e) {
      debugPrint('Error in addAcademy: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<void>> deleteAcademy(String contentId) async {
    try {
      await SupabaseService.client
          .from('academy_content')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', contentId);

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> updateAcademy(
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
      if (externalSharePlatforms != null) {
        updates['external_share_platforms'] = externalSharePlatforms;
      }

      if (updates.isEmpty) {
        return const Success(null); // nothing to update
      }

      await SupabaseService.client
          .from('academy_content')
          .update(updates)
          .eq('id', contentId);

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<AcademyContentModel?>> getAcademyById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('academy_content')
          .select()
          .eq('id', id)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      final content = AcademyContentModel.fromJson(response);
      return Success(content);
    } catch (e) {
      debugPrint('Error in getAcademyById: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
