import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Domain model representing a student's subscription.
/// Source of truth: RevenueCat entitlement check (real-time) +
/// Supabase subscriptions table (webhook-written, async).
@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String studentId,
    required String status,
    String? platform,
    String? productId,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  factory Subscription.fromSupabaseRow(Map<String, dynamic> row) =>
      Subscription(
        id: row['id'] as String,
        studentId: row['student_id'] as String,
        status: row['status'] as String,
        platform: row['platform'] as String?,
        productId: row['product_id'] as String?,
        currentPeriodStart: row['current_period_start'] != null
            ? DateTime.parse(row['current_period_start'] as String)
            : null,
        currentPeriodEnd: row['current_period_end'] != null
            ? DateTime.parse(row['current_period_end'] as String)
            : null,
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : null,
      );
}

/// Whether a subscription is currently active.
extension SubscriptionStatus on Subscription {
  bool get isActive => status == 'active';
  bool get isGracePeriod => status == 'grace_period';
  bool get isExpired => status == 'expired' || status == 'cancelled';
}
