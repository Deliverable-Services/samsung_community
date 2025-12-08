import 'package:flutter/cupertino.dart';

import '../main.dart';

class AppState {
  AppState._internal();

  static final AppState instance = AppState._internal();

  factory AppState() => instance;
  static bool _isUser = false;

  set setIsLogin(bool isLogin) => _isUser = isLogin;

  bool get getIsLogin => _isUser;

  double get getScreenHeight =>
      MediaQuery.of(navigatorKey.currentContext!).size.height;

  double get getScreenWidth =>
      MediaQuery.of(navigatorKey.currentContext!).size.width;
}
