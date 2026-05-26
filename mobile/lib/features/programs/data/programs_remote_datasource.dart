import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cqrs/query_gateway.dart';
import '../domain/program_model.dart';

part 'programs_remote_datasource.g.dart';

/// Reads program catalog from QueryGateway (Supabase program_catalog_view).
///
/// QueryGateway handles online/offline fallback internally:
/// - Online: reads from program_catalog_view (includes is_subscribed, enrollment_id)
/// - Offline: falls back to local Drift programs (without is_subscribed)
class ProgramsRemoteDatasource {
  ProgramsRemoteDatasource(this._queryGateway);
  final QueryGateway _queryGateway;

  /// Fetch all published programs from the catalog view.
  /// Returns ProgramModel list with enrollment and subscription overlay.
  Future<List<ProgramModel>> getPrograms() async {
    final rows = await _queryGateway.getProgramCatalog();
    return rows.map(ProgramModel.fromCatalogRow).toList();
  }
}

@riverpod
ProgramsRemoteDatasource programsRemoteDatasource(Ref ref) {
  final gateway = ref.watch(queryGatewayProvider);
  return ProgramsRemoteDatasource(gateway);
}
