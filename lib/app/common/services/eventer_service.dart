import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/constants/app_consts.dart';

/// Service for handling Eventer API interactions
class EventerService {
  /// Report payment result to Eventer
  ///
  /// [saleNumber] - The sale number from Eventer
  /// [guid] - The GUID from Eventer
  /// [isSuccess] - Whether the payment was successful
  /// [error] - Optional error message for logging
  /// [confirmationKey] - Optional external order number
  static Future<Map<String, dynamic>?> reportPaymentResult({
    required int saleNumber,
    required String guid,
    required bool isSuccess,
    String? error,
    String? confirmationKey,
  }) async {
    try {
      final url =
          '${AppConst.eventerApiUrl}/privateProviderRedirectEnd/$saleNumber/$guid';

      final body = {
        'isSuccess': isSuccess,
        'error': ?error,
        'confirmationKey': ?confirmationKey,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to report payment: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error reporting payment result: $e');
    }
  }

  /// Build Eventer iframe URL with PenPal configuration
  ///
  /// [eventId] - The Eventer event ID (e.g., 'yp93f' or UUID)
  /// [options] - Optional configuration options
  static String buildEventerIframeUrl({
    required String eventId,
    String? lang,
    String? colorScheme,
    String? colorScheme2,
    String? colorSchemeButton,
    bool showBanner = false,
    bool showEventDetails = false,
    bool showBackground = true,
    bool showLocationDescription = false,
    bool showSeller = false,
    bool showPoweredBy = false,
  }) {
    final baseUrl = '${AppConst.eventerBaseUrl}/$eventId';
    final params = <String>[];

    // Language parameter
    if (lang != null) {
      params.add('lang=$lang');
    }

    // Color scheme parameters (URL encoded)
    if (colorScheme != null) {
      params.add('colorScheme=${Uri.encodeComponent(colorScheme)}');
    }
    if (colorScheme2 != null) {
      params.add('colorScheme2=${Uri.encodeComponent(colorScheme2)}');
    }
    if (colorSchemeButton != null) {
      params.add('colorSchemeButton=${Uri.encodeComponent(colorSchemeButton)}');
    }

    // Section visibility parameters
    params.add('lpsec_poweredByBox_0=${showPoweredBy ? 1 : 0}');
    params.add('lpsec_banner_1_${showBanner ? "true" : "false"}=0');
    params.add('lpsec_purchaseBox_2=0');
    params.add('lpsec_eventDetails_3_${showEventDetails ? "true" : "false"}=0');
    params.add('lpf_showBackground=${showBackground ? "true" : "false"}');
    params.add(
      'lpf_showLocationDescription=${showLocationDescription ? "true" : "false"}',
    );
    if (showSeller) {
      params.add('showseller=true');
    }

    final queryString = params.join('&');
    return queryString.isNotEmpty ? '$baseUrl?$queryString' : baseUrl;
  }
}
