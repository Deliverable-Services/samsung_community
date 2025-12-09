import 'package:get/get.dart';
import 'hebrew_localization.dart';
import 'en_localization.dart';

class LocalString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': EnLocalization.enLang,
    'hindi': HebrewiLocalization.hebrewLang,
  };
}
