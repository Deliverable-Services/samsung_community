import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConst {
  static const String appName = 'Samsung', currentLocale = "currentLocale";
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Eventer Configuration
  static String get eventerClientId => dotenv.env['EVENTER_CLIENT_ID'] ?? '';
  static String get eventerClientSecret => dotenv.env['EVENTER_CLIENT_SECRET'] ?? '';
  static String get eventerConnectUrl => dotenv.env['EVENTER_CONNECT_URL'] ?? 'www.eventer.co.il';
  static String get eventerBaseUrl => 'https://$eventerConnectUrl';
  static String get eventerApiUrl => '$eventerBaseUrl/restapi';
}
