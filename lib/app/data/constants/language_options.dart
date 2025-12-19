class LanguageOption {
  final String id;
  final String name;
  final String locale;
  final String boxText;

  const LanguageOption({
    required this.id,
    required this.name,
    required this.locale,
    required this.boxText,
  });
}

class LanguageOptions {
  LanguageOptions._();

  static const List<LanguageOption> options = [
    LanguageOption(id: 'en', name: 'English', locale: 'en', boxText: 'A'),
    LanguageOption(id: 'he', name: 'Hebrew', locale: 'he', boxText: 'א'),
  ];

  static Map<String, LanguageOption> get optionsMap {
    return {for (var option in options) option.id: option};
  }
}
