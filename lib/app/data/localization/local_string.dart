import 'package:get/get.dart';

import 'en_localization.dart';
import 'hebrew_localization.dart';

class LocalString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': EnLocalization.enLang,
    'he': HebrewiLocalization.hebrewLang,
  };
}
