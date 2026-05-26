import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_provider.dart';
import 'subscription_repository.dart';

part 'subscription_provider.g.dart';

/// Whether the current user has an active subscription.
///
/// Checks RevenueCat entitlement 'premium_access' first,
/// falls back to Supabase subscriptions table, then SharedPreferences cache.
/// Returns false if no user is signed in.
@riverpod
Future<bool> isSubscribed(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.isSubscribed(user.id);
}
