import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => Supabase.instance.client.auth;

  static bool get isAuthenticated => auth.currentUser != null;

  static User? get currentUser => auth.currentUser;

  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      debugPrint('Error in signOut: $e');
    }
  }
}
