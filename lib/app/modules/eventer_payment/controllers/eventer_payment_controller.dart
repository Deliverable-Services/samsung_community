import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/services/eventer_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../events/controllers/events_controller.dart';
import '../local_widgets/registration_modals.dart';

class EventerPaymentController extends GetxController {
  WebViewController? webViewController;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool penpalReady = false.obs;
  final RxBool registrationCompleted = false.obs;

  String? eventerEventId; // Eventer ID (e.g., 'yp93f')
  String? supabaseEventId; // Supabase Event ID (UUID)
  String? directUrl; // Optional direct URL (e.g., order cancellation)
  String? email;
  Map<String, dynamic>? initialConfig;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;

    directUrl = arguments?['url'] as String?;

    if (directUrl == null) {
      supabaseEventId = arguments?['eventId'] as String?;
      eventerEventId =
          (arguments?['external_id'] as String?) ?? supabaseEventId;

      email = arguments?['email'] as String?;
      initialConfig = arguments?['config'] as Map<String, dynamic>?;

      if (eventerEventId == null || eventerEventId!.isEmpty) {
        errorMessage.value = 'Event ID is required';
        isLoading.value = false;
        return;
      }
    }

    _initializeWebView();
  }

  void _initializeWebView() {
    if (webViewController != null) {
      webViewController!.reload();
      return;
    }

    // Build the URL (either direct or Eventer iframe)
    final eventUrl =
        directUrl ??
        EventerService.buildEventerIframeUrl(
          eventId: eventerEventId!,
          lang: initialConfig?['lang'] ?? 'en_EN',
          colorScheme: initialConfig?['colorScheme'] ?? '#FFFFFF',
          colorScheme2: initialConfig?['colorScheme2'] ?? '#000000',
          colorSchemeButton: initialConfig?['colorSchemeButton'] ?? '#1FA3FF',
          showBanner: initialConfig?['showBanner'] ?? false,
          showEventDetails: initialConfig?['showEventDetails'] ?? false,
          showBackground: initialConfig?['showBackground'] ?? true,
          showLocationDescription:
              initialConfig?['showLocationDescription'] ?? false,
          showSeller: initialConfig?['showSeller'] ?? false,
          showPoweredBy: initialConfig?['showPoweredBy'] ?? false,
        );

    debugPrint('Opening Eventer URL: $eventUrl');

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.primary)
      ..enableZoom(false)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isLoading.value = true;
            errorMessage.value = '';
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            errorMessage.value = '';
            // Inject PenPal communication script after page loads
            Future.delayed(const Duration(milliseconds: 500), () {
              if (Get.isRegistered<EventerPaymentController>()) {
                _injectPenPalScript();
              }
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('eventer.co.il') ||
                request.url.contains('eventer.us')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            if (registrationCompleted.value) {
              return;
            }

            // Handle ORB errors gracefully
            if (error.description.contains('ORB') ||
                error.description.contains('ERR_BLOCKED_BY_ORB') ||
                error.description.contains('opaque response')) {
              return;
            }

            // Only show error for critical errors
            if (error.errorCode == -2 || // ERR_INTERNET_DISCONNECTED
                error.errorCode == -3 || // ERR_PROXY_CONNECTION_FAILED
                error.errorCode == -6 || // ERR_FILE_NOT_FOUND
                error.errorCode == -105 || // ERR_NAME_NOT_RESOLVED
                error.errorCode == -106) {
              isLoading.value = false;
              errorMessage.value =
                  '${error.description} (Error: ${error.errorCode})';
            }
          },
          onHttpError: (HttpResponseError error) {
            if (error.response?.statusCode != null &&
                error.response!.statusCode >= 400) {
              isLoading.value = false;
              errorMessage.value =
                  'HTTP ${error.response!.statusCode}: Failed to load page';
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(eventUrl));
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final payload = data['payload'];

      if (type == null) {
        return;
      }

      Map<String, dynamic>? payloadMap;
      if (payload is Map<String, dynamic>) {
        payloadMap = payload;
      } else if (payload is Map) {
        payloadMap = Map<String, dynamic>.from(payload);
      }

      switch (type) {
        case 'notifyIframeReady':
          _handleIframeReady(payloadMap);
          break;
        case 'notifySaleSuccess':
          _handleSaleSuccess(payloadMap);
          break;
        case 'notifyTicketChange':
          _handleTicketChange(payloadMap);
          break;
        case 'onSaleSuccess':
        case 'PurchaseSuccess':
          _handleOnSaleSuccess(payloadMap);
          break;
        case 'penpalReady':
          penpalReady.value = true;
          _prefillGuestDetailsIfAvailable();
          break;
      }
    } catch (e) {}
  }

  void _handleIframeReady(Map<String, dynamic>? data) {
    _prefillGuestDetailsIfAvailable();
  }

  void _prefillGuestDetailsIfAvailable() {
    if (email != null && email!.isNotEmpty) {
      _callEventerMethod('setGuestDetails', [
        {'email': email},
        false,
      ]);
    }
  }

  void _injectPenPalScript() {
    webViewController?.runJavaScript(r'''
      (function() {
        function sendToFlutter(message) {
          if (window.FlutterChannel) {
            window.FlutterChannel.postMessage(JSON.stringify(message));
          }
        }

        window.addEventListener('message', function(event) {
          try {
            var data = event.data || {};
            var type = data.type || data.event;
            var payload = data.payload || data.data || null;

            if (!type) {
              sendToFlutter({ type: 'unknown', payload: data });
              return;
            }

            sendToFlutter({ type: type, payload: payload });
          } catch (e) {
            sendToFlutter({ type: 'bridgeError', payload: String(e) });
          }
        });

        sendToFlutter({ type: 'penpalReady' });
      })();
    ''');
  }

  void _handleSaleSuccess(Map<String, dynamic>? data) {
    if (data != null) {
      _processPayment(data);
    }
  }

  void _handleTicketChange(Map<String, dynamic>? data) {
    // Handle ticket selection changes if needed
  }

  void _handleOnSaleSuccess(Map<String, dynamic>? data) {
    _showPaymentResult(true, data);
  }

  Future<void> _processPayment(Map<String, dynamic> saleData) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final saleNumber = saleData['saleNumber'] as int?;
      final guid = saleData['guid'] as String?;

      if (saleNumber != null && guid != null) {
        final result = await EventerService.reportPaymentResult(
          saleNumber: saleNumber,
          guid: guid,
          isSuccess: true,
          confirmationKey: 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
        );

        Get.back();
        _showPaymentResult(true, result);
      } else {
        Get.back();
        _showPaymentResult(true, null);
      }
    } catch (e) {
      Get.back();
      _showPaymentResult(true, null);
    }
  }

  void _showPaymentResult(
    bool success,
    Map<String, dynamic>? data, {
    String? error,
  }) {
    final context = Get.context;
    if (context == null) return;

    if (success) {
      registrationCompleted.value = true;

      // Record registration in API immediately
      _addRegistrationToAPI();

      // Do NOT close the webview automatically.
      // User will close it manually.
    } else {
      // For errors, show cancelled modal
      Get.back();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          RegistrationCancelledModal.show(Get.context!);
        }
      });
    }
  }

  /// Handle back button press
  void handleBackButton() {
    if (registrationCompleted.value) {
      // If registration was successful, just close and show success modal
      Get.back();

      // Reload events to refresh the UI (e.g. show cancel button)
      try {
        final eventsController = Get.find<EventsController>();
        eventsController.loadAllEvents();
        eventsController.loadMyEvents();
        eventsController.fetchRegisteredUserEvents();
      } catch (e) {}

      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          RegistrationSuccessModal.show(Get.context!);
        }
      });
    } else {
      final context = Get.context;
      if (context != null) {
        // Close payment screen first
        Get.back();
        // Show cancelled modal after a small delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.context != null) {
            RegistrationCancelledModal.show(Get.context!);
          }
        });
      } else {
        Get.back();
      }
    }
  }

  Future<void> _addRegistrationToAPI() async {
    if (supabaseEventId == null) {
      return;
    }

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        return;
      }

      // Check if already registered
      final existingRegistration = await SupabaseService.client
          .from('event_registrations')
          .select('id')
          .eq('event_id', supabaseEventId!)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingRegistration != null) {
        return;
      }

      await SupabaseService.client.from('event_registrations').insert({
        'event_id': supabaseEventId,
        'user_id': userId,
        if (email != null && email!.isNotEmpty) 'email_for_tickets': email,
        'payment_method': 'credit_card', // Assuming credit card for Eventer
        'points_paid': 0,
        'status': 'registered',
        'registered_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {}
  }

  Future<void> _callEventerMethod(
    String methodName, [
    List<dynamic>? args,
  ]) async {
    if (!penpalReady.value) {
      return;
    }

    try {
      final argsJson = args != null ? jsonEncode(args) : '[]';
      await webViewController?.runJavaScript('''
        if (window.callEventerMethod) {
          window.callEventerMethod('$methodName', ...$argsJson);
        }
      ''');
    } catch (e) {}
  }

  void reload() {
    errorMessage.value = '';
    isLoading.value = true;
    webViewController?.reload();
  }

  @override
  void onClose() {
    webViewController = null;
    super.onClose();
  }
}
