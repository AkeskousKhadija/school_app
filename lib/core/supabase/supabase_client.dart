import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:school_app/core/config/supabase_config.dart';

class SupabaseClientProvider {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    String? url,
    String? anonKey,
  }) async {
    final finalUrl = url ?? SupabaseConfig.supabaseUrl;
    final finalKey = anonKey ?? SupabaseConfig.supabaseAnonKey;

    if (finalUrl.isEmpty || finalKey.isEmpty) {
      throw Exception('Supabase URL or Anon Key is missing. Use --dart-define or .vscode/launch.json');
    }

    await Supabase.initialize(
      url: finalUrl,
      anonKey: finalKey,
      debug: false,
    );
  }
}
