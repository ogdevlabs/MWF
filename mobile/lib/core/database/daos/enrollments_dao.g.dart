// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollments_dao.dart';

// ignore_for_file: type=lint
mixin _$EnrollmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalEnrollmentsTable get localEnrollments =>
      attachedDatabase.localEnrollments;
  EnrollmentsDaoManager get managers => EnrollmentsDaoManager(this);
}

class EnrollmentsDaoManager {
  final _$EnrollmentsDaoMixin _db;
  EnrollmentsDaoManager(this._db);
  $$LocalEnrollmentsTableTableManager get localEnrollments =>
      $$LocalEnrollmentsTableTableManager(
        _db.attachedDatabase,
        _db.localEnrollments,
      );
}
