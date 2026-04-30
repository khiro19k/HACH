import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://jjqowlxicawxglzxumlv.supabase.co';
  static const String anonKey = 'sb_publishable_jtDzP6qcWrr1VR1Dfxf8Mw_1DhBqKGl';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
