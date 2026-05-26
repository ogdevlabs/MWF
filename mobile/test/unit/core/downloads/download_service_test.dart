import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/database/app_database.dart';
import 'package:mwf_mobile/core/downloads/download_service.dart';

void main() {
  late AppDatabase db;
  late DownloadService service;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    service = DownloadService(db: db);
    // Note: Do NOT call service.initialize() in tests — it requires
    // FileDownloader singleton which needs platform channels
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  test('service creates with database reference', () {
    expect(service, isNotNull);
  });

  test('progressStream is a broadcast stream', () {
    expect(service.progressStream.isBroadcast, isTrue);
  });
}
