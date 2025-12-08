import 'package:get_storage/get_storage.dart';

class GetPrefs {
  static late GetStorage _getStorage;

  static Future init() async => _getStorage = GetStorage();

  static const String isLoggedIn = "is_logged_in";

  static void setString(String key, String value) =>
      _getStorage.write(key, value);

  static void setInt(String key, int value) => _getStorage.write(key, value);

  static void setBool(String key, bool value) => _getStorage.write(key, value);

  static bool containsKey(String key) => _getStorage.hasData(key);

  static Future clear() async => await _getStorage.erase();

  static String getString(String key) => _getStorage.read(key) ?? '';

  static bool getBool(String key) => _getStorage.read(key) ?? false;

  static int getInt(String key) => _getStorage.read(key) ?? 0;

  static remove(String key) => _getStorage.remove(key);
}
