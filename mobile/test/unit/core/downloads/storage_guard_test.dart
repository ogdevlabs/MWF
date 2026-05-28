import 'package:flutter_test/flutter_test.dart';
import 'package:mwf_mobile/core/downloads/storage_guard.dart';

void main() {
  group('StorageGuard', () {
    test('returns false when freeSpace < 500 MB threshold', () async {
      final result = await StorageGuard.hasEnoughSpace(
        thresholdBytes: 500 * 1024 * 1024,
        freeSpaceProvider: () async => 100 * 1024 * 1024,
      );
      expect(result, isFalse);
    });

    test('returns true when freeSpace >= 500 MB threshold', () async {
      final result = await StorageGuard.hasEnoughSpace(
        thresholdBytes: 500 * 1024 * 1024,
        freeSpaceProvider: () async => 1024 * 1024 * 1024, // 1 GB
      );
      expect(result, isTrue);
    });

    test('returns true (fail-open) when freeSpaceProvider throws', () async {
      final result = await StorageGuard.hasEnoughSpace(
        thresholdBytes: 500 * 1024 * 1024,
        freeSpaceProvider: () async => throw Exception('disk_space error'),
      );
      expect(result, isTrue);
    });
  });
}
