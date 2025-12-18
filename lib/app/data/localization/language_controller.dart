import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_consts.dart';
import '../constants/language_options.dart';
import 'get_prefs.dart';

class LanguageController extends GetxController {
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  @override
  void onInit() {
    super.onInit();
    // Load saved locale from storage
    if (GetPrefs.containsKey(AppConst.currentLocale)) {
      _currentLocale = GetPrefs.getString(AppConst.currentLocale);
      // Update GetX locale
      Get.updateLocale(Locale(_currentLocale));
    }
  }

  /// Change language and persist it
  void changeLanguage(String languageId) {
    try {
      final option = LanguageOptions.options.firstWhere(
        (opt) => opt.id == languageId,
      );
      _currentLocale = option.locale;
      // Save to persistent storage
      GetPrefs.setString(AppConst.currentLocale, _currentLocale);
      // Update GetX locale (this will update the UI automatically)
      Get.updateLocale(Locale(_currentLocale));
      update(); // Notify listeners
    } catch (e) {
      // Language option not found, do nothing
    }
  }
}
