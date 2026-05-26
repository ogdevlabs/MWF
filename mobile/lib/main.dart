import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/theme/app_theme.dart';
import 'shared/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // TODO Phase 7: Initialize Firebase
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MwfApp()));
}

class MwfApp extends StatelessWidget {
  const MwfApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Phase 2: Replace with Riverpod-driven auth state
    final router = createAppRouter(isAuthenticated: false);

    return MaterialApp.router(
      title: 'Mat Pilates Coach',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
