import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'shared/theme/app_theme.dart';
import 'shared/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  // Hard fail in debug mode so missing credentials are immediately visible.
  // In release the app would just show empty data — make it obvious in dev.
  assert(
    supabaseUrl.isNotEmpty,
    '\n\n'
    '╔══════════════════════════════════════════════════════════╗\n'
    '║  SUPABASE_URL is not set.                                ║\n'
    '║  Run the app via:  ./local-dev/dev.sh mobile-only        ║\n'
    '║  Or pass:          --dart-define=SUPABASE_URL=https://...║\n'
    '╚══════════════════════════════════════════════════════════╝\n',
  );

  await Supabase.initialize(
    url: supabaseUrl.isNotEmpty
        ? supabaseUrl
        : 'https://rlcgtqagfdweisnxrasn.supabase.co',
    anonKey: supabaseKey,
  );

  const rcAppleKey = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  const rcGoogleKey = String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');
  final rcApiKey = defaultTargetPlatform == TargetPlatform.iOS
      ? rcAppleKey
      : rcGoogleKey;
  if (rcApiKey.isNotEmpty) {
    await Purchases.configure(PurchasesConfiguration(rcApiKey));
  }

  runApp(const ProviderScope(child: MwfApp()));
}

class MwfApp extends ConsumerWidget {
  const MwfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use read — the router is keepAlive and must not be recreated on rebuild.
    final router = ref.read(appRouterProvider);

    return MaterialApp.router(
      title: 'Move With Fergie',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
