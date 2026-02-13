import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/services/supabase_service.dart';
import '../../data/models/user_model.dart';
import '../../data/core/utils/result.dart';

class UserRepo {
  final SupabaseClient _supabaseClient = SupabaseService.client;

  Future<Result<List<UserModel>>> getPendingUsers() async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('status', UserStatus.pending.name); // Using .name for enum string value

      final List<dynamic> data = response as List<dynamic>;
      final users = data.map((json) => UserModel.fromJson(json)).toList();
      return Success(users);
    } catch (e) {
      debugPrint('Error fetching pending users: $e');
      return Failure(e.toString());
    }
  }

  Future<Result<bool>> updateUserStatus(String userId, UserStatus status) async {
    try {
      // Assuming 'approved_at' and 'approved_by' should be updated on approval
      final Map<String, dynamic> updates = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == UserStatus.approved) {
        updates['approved_at'] = DateTime.now().toIso8601String();
        updates['approved_by'] = _supabaseClient.auth.currentUser?.id; 
      }

      await _supabaseClient
          .from('users')
          .update(updates)
          .eq('id', userId);
      
      return Success(true);
    } catch (e) {
      debugPrint('Error updating user status: $e');
      return Failure(e.toString());
    }
  }
}
