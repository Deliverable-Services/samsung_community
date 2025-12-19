import 'package:get/get.dart';

import '../utils/common_snackbar.dart';

/// Base controller class for all controllers
/// Provides common functionality and lifecycle management
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  /// Set loading state
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  /// Set error state
  void setError(String? error) {
    hasError.value = error != null && error.isNotEmpty;
    errorMessage.value = error ?? '';
  }

  /// Clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Handle errors consistently
  void handleError(dynamic error) {
    setError(error.toString());
    setLoading(false);
    CommonSnackbar.error(error.toString());
  }

  @override
  void onClose() {
    clearError();
    super.onClose();
  }
}
