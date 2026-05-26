import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client.g.dart';

/// Provides the initialized [SupabaseClient] singleton.
///
/// Requires [Supabase.initialize] to have been called in main() before
/// the app starts. Uses keepAlive because the client must persist for
/// the entire app lifecycle — autoDispose would close connections mid-operation.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
