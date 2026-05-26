import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'shared/theme/app_theme.dart';
import 'shared/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // RevenueCat initialization — platform-specific API key via dart-define.
  // Do NOT set appUserID here; call Purchases.logIn(supabaseUserId) after auth.
  const rcAppleKey = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  const rcGoogleKey = String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');
  final rcApiKey = defaultTargetPlatform == TargetPlatform.iOS
      ? rcAppleKey
      : rcGoogleKey;
  if (rcApiKey.isNotEmpty) {
    await Purchases.configure(PurchasesConfiguration(rcApiKey));
  }

  // TODO Phase 7: Initialize Firebase
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MwfApp()));
}

class MwfApp extends ConsumerWidget {
  const MwfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Move With Fergie',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
