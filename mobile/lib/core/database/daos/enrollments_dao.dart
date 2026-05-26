import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/enrollments_table.dart';

part 'enrollments_dao.g.dart';

@DriftAccessor(tables: [LocalEnrollments])
class EnrollmentsDao extends DatabaseAccessor<AppDatabase> with _$EnrollmentsDaoMixin {
  EnrollmentsDao(super.attachedDatabase);

  /// Watch all enrollments for reactive UI updates.
  Stream<List<LocalEnrollment>> watchAllEnrollments() =>
      select(localEnrollments).watch();

  /// Get all enrollments.
  Future<List<LocalEnrollment>> getAllEnrollments() =>
      select(localEnrollments).get();

  /// Get enrollments for a specific student.
  Future<List<LocalEnrollment>> getEnrollmentsByStudent(String studentId) =>
      (select(localEnrollments)..where((t) => t.studentId.equals(studentId))).get();

  /// Get enrollment by ID.
  Future<LocalEnrollment?> getEnrollmentById(String id) =>
      (select(localEnrollments)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get enrollment for a specific student + program combination.
  Future<LocalEnrollment?> getEnrollment({
    required String studentId,
    required String programId,
  }) =>
      (select(localEnrollments)
            ..where((t) => t.studentId.equals(studentId) & t.programId.equals(programId)))
          .getSingleOrNull();

  /// Upsert enrollment (insert or update on conflict).
  Future<void> upsertEnrollment(LocalEnrollmentsCompanion entry) =>
      into(localEnrollments).insertOnConflictUpdate(entry);

  /// Update current day for an enrollment.
  Future<void> updateCurrentDay(String enrollmentId, int day) =>
      (update(localEnrollments)..where((t) => t.id.equals(enrollmentId)))
          .write(LocalEnrollmentsCompanion(currentDay: Value(day)));

  /// Delete enrollment by ID.
  Future<int> deleteEnrollmentById(String id) =>
      (delete(localEnrollments)..where((t) => t.id.equals(id))).go();
}
