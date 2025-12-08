import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

import 'constants/app_consts.dart';
import 'services/app_routes.dart';
import 'services/get_prefs.dart';
import 'services/localization/local_string.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await GetPrefs.init();
  runApp(const MainApp());
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String currentLocale = 'en';

  @override
  void initState() {
    if (GetPrefs.containsKey(AppConst.currentLocale)) {
      currentLocale = GetPrefs.getString(AppConst.currentLocale);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Rubik'),
      navigatorKey: navigatorKey,
      getPages: AppRouteName.routes,
      initialRoute: AppRouteName.welcomeScreen,
      translations: LocalString(),
      locale: Locale(currentLocale),
      // home: const WelcomeScreen(),
    );
  }
}
