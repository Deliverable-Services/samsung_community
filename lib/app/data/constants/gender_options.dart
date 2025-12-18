class GenderOption {
  final String id;
  final String name;
  final String boxText;

  const GenderOption({
    required this.id,
    required this.name,
    required this.boxText,
  });
}

class GenderOptions {
  GenderOptions._();

  static const List<GenderOption> options = [
    GenderOption(id: 'male', name: 'Male', boxText: 'M'),
    GenderOption(id: 'female', name: 'Female', boxText: 'F'),
    GenderOption(id: 'other', name: 'Others', boxText: 'O'),
  ];

  static Map<String, GenderOption> get optionsMap {
    return {for (var option in options) option.id: option};
  }
}
