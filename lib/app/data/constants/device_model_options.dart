class DeviceModelOption {
  final String id;
  final String name;
  final String boxText;

  const DeviceModelOption({
    required this.id,
    required this.name,
    required this.boxText,
  });
}

class DeviceModelOptions {
  DeviceModelOptions._();

  static const List<DeviceModelOption> options = [
    // Galaxy S Series
    DeviceModelOption(
      id: 'galaxy_s24_ultra',
      name: 'Galaxy S24 Ultra',
      boxText: 'S24U',
    ),
    DeviceModelOption(
      id: 'galaxy_s24_plus',
      name: 'Galaxy S24+',
      boxText: 'S24+',
    ),
    DeviceModelOption(id: 'galaxy_s24', name: 'Galaxy S24', boxText: 'S24'),
    DeviceModelOption(
      id: 'galaxy_s23_ultra',
      name: 'Galaxy S23 Ultra',
      boxText: 'S23U',
    ),
    DeviceModelOption(
      id: 'galaxy_s23_plus',
      name: 'Galaxy S23+',
      boxText: 'S23+',
    ),
    DeviceModelOption(id: 'galaxy_s23', name: 'Galaxy S23', boxText: 'S23'),
    DeviceModelOption(
      id: 'galaxy_s22_ultra',
      name: 'Galaxy S22 Ultra',
      boxText: 'S22U',
    ),
    DeviceModelOption(
      id: 'galaxy_s22_plus',
      name: 'Galaxy S22+',
      boxText: 'S22+',
    ),
    DeviceModelOption(id: 'galaxy_s22', name: 'Galaxy S22', boxText: 'S22'),
    DeviceModelOption(
      id: 'galaxy_s21_ultra',
      name: 'Galaxy S21 Ultra',
      boxText: 'S21U',
    ),
    DeviceModelOption(
      id: 'galaxy_s21_plus',
      name: 'Galaxy S21+',
      boxText: 'S21+',
    ),
    DeviceModelOption(id: 'galaxy_s21', name: 'Galaxy S21', boxText: 'S21'),
    DeviceModelOption(
      id: 'galaxy_s20_ultra',
      name: 'Galaxy S20 Ultra',
      boxText: 'S20U',
    ),
    DeviceModelOption(
      id: 'galaxy_s20_plus',
      name: 'Galaxy S20+',
      boxText: 'S20+',
    ),
    DeviceModelOption(id: 'galaxy_s20', name: 'Galaxy S20', boxText: 'S20'),

    // Galaxy Note Series
    DeviceModelOption(
      id: 'galaxy_note_20_ultra',
      name: 'Galaxy Note 20 Ultra',
      boxText: 'N20U',
    ),
    DeviceModelOption(
      id: 'galaxy_note_20',
      name: 'Galaxy Note 20',
      boxText: 'N20',
    ),
    DeviceModelOption(
      id: 'galaxy_note_10_plus',
      name: 'Galaxy Note 10+',
      boxText: 'N10+',
    ),
    DeviceModelOption(
      id: 'galaxy_note_10',
      name: 'Galaxy Note 10',
      boxText: 'N10',
    ),

    // Galaxy Z Series (Foldables)
    DeviceModelOption(
      id: 'galaxy_z_fold_5',
      name: 'Galaxy Z Fold 5',
      boxText: 'ZF5',
    ),
    DeviceModelOption(
      id: 'galaxy_z_fold_4',
      name: 'Galaxy Z Fold 4',
      boxText: 'ZF4',
    ),
    DeviceModelOption(
      id: 'galaxy_z_fold_3',
      name: 'Galaxy Z Fold 3',
      boxText: 'ZF3',
    ),
    DeviceModelOption(
      id: 'galaxy_z_flip_5',
      name: 'Galaxy Z Flip 5',
      boxText: 'ZFL5',
    ),
    DeviceModelOption(
      id: 'galaxy_z_flip_4',
      name: 'Galaxy Z Flip 4',
      boxText: 'ZFL4',
    ),
    DeviceModelOption(
      id: 'galaxy_z_flip_3',
      name: 'Galaxy Z Flip 3',
      boxText: 'ZFL3',
    ),

    // Galaxy A Series
    DeviceModelOption(id: 'galaxy_a54', name: 'Galaxy A54', boxText: 'A54'),
    DeviceModelOption(id: 'galaxy_a34', name: 'Galaxy A34', boxText: 'A34'),
    DeviceModelOption(id: 'galaxy_a24', name: 'Galaxy A24', boxText: 'A24'),
    DeviceModelOption(id: 'galaxy_a14', name: 'Galaxy A14', boxText: 'A14'),
    DeviceModelOption(id: 'galaxy_a53', name: 'Galaxy A53', boxText: 'A53'),
    DeviceModelOption(id: 'galaxy_a33', name: 'Galaxy A33', boxText: 'A33'),
    DeviceModelOption(id: 'galaxy_a52', name: 'Galaxy A52', boxText: 'A52'),
    DeviceModelOption(id: 'galaxy_a32', name: 'Galaxy A32', boxText: 'A32'),

    // Galaxy Tab Series
    DeviceModelOption(
      id: 'galaxy_tab_s9_ultra',
      name: 'Galaxy Tab S9 Ultra',
      boxText: 'TS9U',
    ),
    DeviceModelOption(
      id: 'galaxy_tab_s9_plus',
      name: 'Galaxy Tab S9+',
      boxText: 'TS9+',
    ),
    DeviceModelOption(
      id: 'galaxy_tab_s9',
      name: 'Galaxy Tab S9',
      boxText: 'TS9',
    ),
    DeviceModelOption(
      id: 'galaxy_tab_s8_ultra',
      name: 'Galaxy Tab S8 Ultra',
      boxText: 'TS8U',
    ),
    DeviceModelOption(
      id: 'galaxy_tab_s8_plus',
      name: 'Galaxy Tab S8+',
      boxText: 'TS8+',
    ),
    DeviceModelOption(
      id: 'galaxy_tab_s8',
      name: 'Galaxy Tab S8',
      boxText: 'TS8',
    ),

    // Galaxy Watch Series
    DeviceModelOption(
      id: 'galaxy_watch_6_classic',
      name: 'Galaxy Watch 6 Classic',
      boxText: 'W6C',
    ),
    DeviceModelOption(
      id: 'galaxy_watch_6',
      name: 'Galaxy Watch 6',
      boxText: 'W6',
    ),
    DeviceModelOption(
      id: 'galaxy_watch_5_pro',
      name: 'Galaxy Watch 5 Pro',
      boxText: 'W5P',
    ),
    DeviceModelOption(
      id: 'galaxy_watch_5',
      name: 'Galaxy Watch 5',
      boxText: 'W5',
    ),

    // Other Samsung Devices
    DeviceModelOption(
      id: 'galaxy_buds_2_pro',
      name: 'Galaxy Buds2 Pro',
      boxText: 'B2P',
    ),
    DeviceModelOption(id: 'galaxy_buds_2', name: 'Galaxy Buds2', boxText: 'B2'),
    DeviceModelOption(
      id: 'galaxy_buds_fe',
      name: 'Galaxy Buds FE',
      boxText: 'BFE',
    ),
  ];

  static Map<String, DeviceModelOption> get optionsMap {
    return {for (var option in options) option.id: option};
  }
}
