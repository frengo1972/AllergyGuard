import 'package:supabase_flutter/supabase_flutter.dart';

/// Client Supabase configurato per AllergyGuard.
class SupabaseClientProvider {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static bool get isAuthenticated => client.auth.currentUser != null;
  static String? get userId => client.auth.currentUser?.id;
}
