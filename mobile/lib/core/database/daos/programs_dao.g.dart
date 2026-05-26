// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs_dao.dart';

// ignore_for_file: type=lint
mixin _$ProgramsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalProgramsTable get localPrograms => attachedDatabase.localPrograms;
  ProgramsDaoManager get managers => ProgramsDaoManager(this);
}

class ProgramsDaoManager {
  final _$ProgramsDaoMixin _db;
  ProgramsDaoManager(this._db);
  $$LocalProgramsTableTableManager get localPrograms =>
      $$LocalProgramsTableTableManager(_db.attachedDatabase, _db.localPrograms);
}
