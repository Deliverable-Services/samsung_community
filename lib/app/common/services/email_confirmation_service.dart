import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/constants/app_consts.dart';
import 'supabase_service.dart';

class EmailConfirmationService {
  Future<bool> confirmUserEmail(String userId, {String? accessToken}) async {
    String? token;

    try {
      final isAlreadyConfirmed = await checkEmailConfirmedStatus(userId);
      if (isAlreadyConfirmed) {
        return true;
      }

      token = accessToken;
      if (token == null) {
        final currentSession = SupabaseService.client.auth.currentSession;
        token = currentSession?.accessToken;
      }

      if (token == null) {
        final anonKey = AppConst.supabaseAnonKey;
        if (anonKey.isNotEmpty) {
          token = anonKey;
        } else {
          return false;
        }
      }

      final supabaseUrl = AppConst.supabaseUrl;
      if (supabaseUrl.isEmpty) {
        return false;
      }

      final edgeFunctionUrl = '$supabaseUrl/functions/v1/auto-confirm-user';

      if (token.isEmpty) {
        return false;
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': AppConst.supabaseAnonKey,
      };

      final body = jsonEncode({'user_id': userId});

      final response = await http
          .post(Uri.parse(edgeFunctionUrl), headers: headers, body: body)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Edge Function request timed out after 10 seconds',
              );
            },
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await Future.delayed(const Duration(milliseconds: 500));
        final isConfirmed = await checkEmailConfirmedStatus(userId);
        return isConfirmed;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error in confirmUserEmail: $e');
      return false;
    }
  }

  Future<bool> checkEmailConfirmedStatus(String userId) async {
    try {
      final currentUser = SupabaseService.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        return currentUser.emailConfirmedAt != null;
      }
      return false;
    } catch (e) {
      debugPrint('Could not verify email confirmation status: $e');
      return false;
    }
  }
}

