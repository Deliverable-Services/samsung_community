import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../common/services/supabase_service.dart';
import '../../../data/core/utils/result.dart';
import 'promotion_model.dart';

class PromotionService {
  static const _url =
      'https://rtpzoevsikruyrmehnxe.supabase.co/functions/v1/get-promotions';

  Future<Result<List<PromotionModel>>> fetchPromotions() async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${SupabaseService.client.auth.currentSession?.accessToken}',
        },
      );

      final body = jsonDecode(response.body);

      print('response body => $body');

      if (response.statusCode == 200) {
        // :white_check_mark: body is directly a List
        final list = (body as List)
            .map((e) => PromotionModel.fromJson(e))
            .toList();

        return Success(list);
      }

      return Failure('Failed to load promotions');
    } catch (e) {
      print('Error => $e');
      return Failure(e.toString());
    }
  }
}
