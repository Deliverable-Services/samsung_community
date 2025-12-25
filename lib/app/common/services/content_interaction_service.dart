import 'package:flutter/foundation.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/user_model copy.dart';
import 'supabase_service.dart';

class ContentInteractionService {
  Future<Result<bool>> toggleLike({
    required String contentId,
    required String userId,
  }) async {
    try {
      final existingLike = await SupabaseService.client
          .from('content_likes')
          .select('id')
          .eq('content_id', contentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        await SupabaseService.client
            .from('content_likes')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .eq('content_id', contentId)
            .eq('user_id', userId);
        return const Success(false);
      } else {
        await SupabaseService.client.from('content_likes').insert({
          'content_id': contentId,
          'user_id': userId,
        });
        return const Success(true);
      }
    } catch (e) {
      debugPrint('Error in toggleLike: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<bool>> isLiked({
    required String contentId,
    required String userId,
  }) async {
    try {
      final like = await SupabaseService.client
          .from('content_likes')
          .select('id')
          .eq('content_id', contentId)
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      return Success(like != null);
    } catch (e) {
      debugPrint('Error in isLiked: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<CommentModel>> addComment({
    required String contentId,
    required String userId,
    required String commentText,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('content_comments')
          .insert({
            'content_id': contentId,
            'user_id': userId,
            'content': commentText.trim(),
          })
          .select()
          .single();

      return Success(CommentModel.fromJson(response));
    } catch (e) {
      debugPrint('Error in addComment: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<List<CommentModel>>> getComments({
    required String contentId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = SupabaseService.client
          .from('content_comments')
          .select()
          .eq('content_id', contentId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      if (offset != null && limit != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final comments = (response as List)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(comments);
    } catch (e) {
      debugPrint('Error in getComments: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<List<UserModel>>> getLikedByUsers({
    required String contentId,
    int limit = 3,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('content_likes')
          .select('user_id, users!inner(*)')
          .eq('content_id', contentId)
          .isFilter('deleted_at', null)
          .limit(limit);

      final users = <UserModel>[];
      for (final item in response as List) {
        if (item['users'] != null) {
          final userData = item['users'] as Map<String, dynamic>;
          users.add(UserModel.fromJson(userData));
        }
      }

      return Success(users);
    } catch (e) {
      debugPrint('Error in getLikedByUsers: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}

