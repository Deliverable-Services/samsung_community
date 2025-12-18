import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Get the Supabase client instance
  ///
  /// Use this to access database, auth, storage, etc.
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the auth instance for authentication operations
  static GoTrueClient get auth => Supabase.instance.client.auth;

  /// Get the storage instance for file operations
  /// Access via: SupabaseService.client.storage.from('bucket').upload(...)
  /// For convenience, you can also use: SupabaseService.client.storage

  /// Check if user is authenticated
  static bool get isAuthenticated => auth.currentUser != null;

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Sign out current user
  static Future<void> signOut() => auth.signOut();
}
