// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_manifest_dao.dart';

// ignore_for_file: type=lint
mixin _$DownloadManifestDaoMixin on DatabaseAccessor<AppDatabase> {
  $DownloadManifestTable get downloadManifest =>
      attachedDatabase.downloadManifest;
  DownloadManifestDaoManager get managers => DownloadManifestDaoManager(this);
}

class DownloadManifestDaoManager {
  final _$DownloadManifestDaoMixin _db;
  DownloadManifestDaoManager(this._db);
  $$DownloadManifestTableTableManager get downloadManifest =>
      $$DownloadManifestTableTableManager(
        _db.attachedDatabase,
        _db.downloadManifest,
      );
}
