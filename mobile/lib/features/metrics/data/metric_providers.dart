import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_queue.dart';
import 'metric_repository.dart';

part 'metric_providers.g.dart';

@Riverpod(keepAlive: true)
MetricRepository metricRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncQueue = ref.watch(syncQueueProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final studentId = supabase.auth.currentUser?.id ?? '';
  return MetricRepository(db: db, syncQueue: syncQueue, studentId: studentId);
}

/// Stream provider family for metric logs filtered by type.
/// Uses manual Riverpod API (not generated) because riverpod_generator cannot
/// resolve Drift-generated LocalMetricLog type for code generation.
final metricLogsByTypeProvider =
    StreamProvider.family<List<LocalMetricLog>, String>((ref, metricType) {
  final repo = ref.watch(metricRepositoryProvider);
  return repo.watchMetricsByType(metricType);
});
