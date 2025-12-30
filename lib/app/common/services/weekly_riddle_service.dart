import 'package:flutter/foundation.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/weekly_riddle_model.dart';
import 'supabase_service.dart';

class WeeklyRiddleService {
  Future<Result<WeeklyRiddleModel?>> getCurrentWeeklyRiddle() async {
    try {
      final now = DateTime.now().toUtc();

      final response = await SupabaseService.client
          .from('weekly_riddles')
          .select('*, question')
          .eq('is_active', true)
          .lte('start_date', now.toIso8601String())
          .gte('end_date', now.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }
      final riddle = WeeklyRiddleModel.fromJson(response);
      debugPrint("full riddle: ${riddle.toJson()}");
      return Success(riddle);
    } catch (e) {
      debugPrint('Error in getCurrentWeeklyRiddle: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<Map<String, dynamic>>> submitRiddleSolution({
    required Map<String, dynamic> submission,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('riddle_submissions')
          .insert(submission)
          .select()
          .maybeSingle();

      if (response == null) {
        return Failure(
          'Riddle submission was not inserted. Check RLS policies.',
        );
      }

      return Success(response);
    } catch (e) {
      debugPrint('Error in submitRiddleSolution: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<bool>> hasUserSubmitted({
    required String riddleId,
    required String userId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('riddle_submissions')
          .select('id')
          .eq('riddle_id', riddleId)
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .maybeSingle();

      return Success(response != null);
    } catch (e) {
      debugPrint('Error in hasUserSubmitted: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
