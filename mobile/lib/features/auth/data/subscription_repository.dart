import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/subscription_model.dart';

part 'subscription_repository.g.dart';

const _kSubscriptionIsActiveKey = 'subscription_is_active';

/// Manages subscription state via RevenueCat + Supabase fallback.
///
/// Priority order for subscription status:
/// 1. RevenueCat getCustomerInfo() — real-time, handles renewals/grace periods
/// 2. Supabase subscriptions table — webhook-written, async fallback on RC error
/// 3. SharedPreferences cached boolean — offline fallback
///
/// Entitlement identifier: 'premium_access' (from docs/external-service-setup.md)
class SubscriptionRepository {
  SubscriptionRepository({
    required this.supabase,
  });

  final SupabaseClient supabase;

  /// Check if user has active subscription via RevenueCat entitlement.
  /// Falls back to Supabase subscriptions table when RevenueCat is
  /// unavailable or not configured (no API key set).
  /// Caches result in SharedPreferences for offline use.
  Future<bool> isSubscribed(String userId) async {
    try {
      final isConfigured = await Purchases.isConfigured;
      if (!isConfigured) {
        // RevenueCat not configured — no API key set (development mode).
        // Fall straight through to Supabase fallback.
        return _checkSupabaseFallback(userId);
      }
      final customerInfo = await Purchases.getCustomerInfo();
      final isActive =
          customerInfo.entitlements.active.containsKey('premium_access');
      await _cacheSubscriptionStatus(isActive);
      return isActive;
    } catch (_) {
      // Catches PlatformException, StateError, and any other RC error.
      // Fall back to Supabase subscriptions table.
      return _checkSupabaseFallback(userId);
    }
  }

  /// Get full subscription details from Supabase table.
  Future<Subscription?> getSubscription(String userId) async {
    try {
      final response = await supabase
          .from('subscriptions')
          .select()
          .eq('student_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return Subscription.fromSupabaseRow(response);
    } catch (_) {
      return null;
    }
  }

  /// Get cached subscription status from SharedPreferences.
  /// Used when both RevenueCat and Supabase are unavailable (offline).
  Future<bool> getCachedSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSubscriptionIsActiveKey) ?? false;
  }

  Future<bool> _checkSupabaseFallback(String userId) async {
    try {
      final rows = await supabase
          .from('subscriptions')
          .select('status')
          .eq('student_id', userId)
          .eq('status', 'active')
          .limit(1);
      final isActive = (rows as List).isNotEmpty;
      await _cacheSubscriptionStatus(isActive);
      return isActive;
    } catch (_) {
      // Both RC and Supabase failed — use cached value
      return getCachedSubscriptionStatus();
    }
  }

  Future<void> _cacheSubscriptionStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSubscriptionIsActiveKey, isActive);
  }
}

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SubscriptionRepository(supabase: supabase);
}
