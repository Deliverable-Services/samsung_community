import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/services/eventer_service.dart';
import '../../../data/constants/app_colors.dart';
import '../local_widgets/registration_modals.dart';

class EventerPaymentController extends GetxController {
  WebViewController? webViewController;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool penpalReady = false.obs;
  final RxBool registrationCompleted = false.obs;

  String? eventId;
  String? email;
  Map<String, dynamic>? initialConfig;

  @override
  void onInit() {
    super.onInit();
    // Get arguments from route
    final arguments = Get.arguments as Map<String, dynamic>?;
    eventId = arguments?['eventId'] as String?;
    email = arguments?['email'] as String?;
    initialConfig = arguments?['config'] as Map<String, dynamic>?;

    if (eventId == null || eventId!.isEmpty) {
      errorMessage.value = 'Event ID is required';
      isLoading.value = false;
      return;
    }

    _initializeWebView();
  }

  void _initializeWebView() {
    if (webViewController != null) {
      webViewController!.reload();
      return;
    }

    // Build the Eventer iframe URL
    final eventUrl = EventerService.buildEventerIframeUrl(
      eventId: eventId!,
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

    print('═══════════════════════════════════════════════════════════');
    print('Eventer Payment URL:');
    print('Event ID: $eventId');
    print('Full URL: $eventUrl');
    print('Email: $email');
    print('═══════════════════════════════════════════════════════════');

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
            print('Page started loading: $url');
            isLoading.value = true;
            errorMessage.value = '';
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
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
            print('Navigation request: ${request.url}');
            // Allow all navigation within Eventer domain
            if (request.url.contains('eventer.co.il') ||
                request.url.contains('eventer.us')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print(
              'Web resource error: ${error.description} (${error.errorCode})',
            );

            // Handle ORB errors gracefully
            if (error.description.contains('ORB') ||
                error.description.contains('ERR_BLOCKED_BY_ORB') ||
                error.description.contains('opaque response')) {
              print('ORB error detected - continuing anyway');
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
            print(
              'HTTP error: ${error.response?.statusCode} - ${error.response?.uri}',
            );
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

      switch (type) {
        case 'notifyIframeReady':
          _handleIframeReady(payload);
          break;
        case 'notifySaleSuccess':
          _handleSaleSuccess(payload);
          break;
        case 'notifyTicketChange':
          _handleTicketChange(payload);
          break;
        case 'onSaleSuccess':
          _handleOnSaleSuccess(payload);
          break;
        case 'penpalReady':
          penpalReady.value = true;
          _prefillGuestDetailsIfAvailable();
          break;
      }
    } catch (e) {
      print('Error handling JavaScript message: $e');
    }
  }

  void _handleIframeReady(Map<String, dynamic>? data) {
    print('Iframe ready: $data');
    _prefillGuestDetailsIfAvailable();
  }

  void _prefillGuestDetailsIfAvailable() {
    if (email != null && email!.isNotEmpty) {
      _callEventerMethod('setGuestDetails', [
        {'email': email},
        false, // isLock - set to false to allow editing
      ]);
    }
  }

  void _injectPenPalScript() {
    // Inject PenPal script and communication bridge after page loads
    webViewController?.runJavaScript(r'''
      (function() {
        // Listen for Eventer's postMessage events
        window.addEventListener('message', function(event) {
          if (event.origin.match(/^https:(\/\/|[^\.]+\.)eventer\.(co\.il|us)$/)) {
            if (event.data && event.data.event === 'eva' && window.FlutterChannel) {
              // Handle Eventer messages
              FlutterChannel.postMessage(JSON.stringify({
                type: 'eventerMessage',
                payload: event.data
              }));
            }
          }
        });
        
        // Notify Flutter that page is ready
        if (window.FlutterChannel) {
          FlutterChannel.postMessage(JSON.stringify({type: 'penpalReady'}));
        }
      })();
    ''');
  }

  void _handleSaleSuccess(Map<String, dynamic>? data) {
    print('Sale success: $data');
    if (data != null) {
      _processPayment(data);
    }
  }

  void _handleTicketChange(Map<String, dynamic>? data) {
    print('Ticket change: $data');
    // Handle ticket selection changes if needed
  }

  void _handleOnSaleSuccess(Map<String, dynamic>? data) {
    print('On sale success: $data');
    _showPaymentResult(true, data);
  }

  Future<void> _processPayment(Map<String, dynamic> saleData) async {
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final saleNumber = saleData['saleNumber'] as int?;
      final guid = saleData['guid'] as String?;

      if (saleNumber != null && guid != null) {
        // Report payment result to Eventer
        final result = await EventerService.reportPaymentResult(
          saleNumber: saleNumber,
          guid: guid,
          isSuccess: true,
          confirmationKey: 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
        );

        Get.back(); // Close loading dialog
        _showPaymentResult(true, result);
      } else {
        Get.back(); // Close loading dialog
        _showPaymentResult(false, null, error: 'Missing sale information');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      _showPaymentResult(false, null, error: e.toString());
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
      // Close payment screen first, then show success modal
      Get.back();
      // Show success modal after a small delay to ensure navigation is complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.context != null) {
          RegistrationSuccessModal.show(Get.context!);
        }
      });
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

  /// Handle back button press - show cancelled modal if registration not completed
  void handleBackButton() {
    if (!registrationCompleted.value) {
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
    } else {
      Get.back();
    }
  }

  Future<void> _callEventerMethod(
    String methodName, [
    List<dynamic>? args,
  ]) async {
    if (!penpalReady.value) {
      print('PenPal not ready yet');
      return;
    }

    try {
      final argsJson = args != null ? jsonEncode(args) : '[]';
      await webViewController?.runJavaScript('''
        if (window.callEventerMethod) {
          window.callEventerMethod('$methodName', ...$argsJson);
        }
      ''');
    } catch (e) {
      print('Error calling Eventer method: $e');
    }
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
