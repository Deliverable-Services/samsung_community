class CollegeOption {
  final String id;
  final String name;

  const CollegeOption({required this.id, required this.name});
}

class CollegeOptions {
  CollegeOptions._();

  static const List<CollegeOption> options = [
    CollegeOption(id: 'college_1', name: 'College 1'),
    CollegeOption(id: 'college_2', name: 'College 2'),
    CollegeOption(id: 'college_3', name: 'College 3'),
    CollegeOption(id: 'college_4', name: 'College 4'),
    CollegeOption(id: 'college_5', name: 'College 5'),
  ];

  static Map<String, CollegeOption> get optionsMap {
    return {for (var option in options) option.id: option};
  }
}
