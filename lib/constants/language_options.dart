class LanguageOption {
  final String id;
  final String name;
  final String locale;

  const LanguageOption({
    required this.id,
    required this.name,
    required this.locale,
  });
}

class LanguageOptions {
  LanguageOptions._();

  static const List<LanguageOption> options = [
    LanguageOption(id: 'en', name: 'English', locale: 'en'),
    LanguageOption(id: 'he', name: 'Hebrew', locale: 'hindi'),
  ];

  static Map<String, LanguageOption> get optionsMap {
    return {for (var option in options) option.id: option};
  }
}
