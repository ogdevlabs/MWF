// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercises_dao.dart';

// ignore_for_file: type=lint
mixin _$ExercisesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalExercisesTable get localExercises => attachedDatabase.localExercises;
  ExercisesDaoManager get managers => ExercisesDaoManager(this);
}

class ExercisesDaoManager {
  final _$ExercisesDaoMixin _db;
  ExercisesDaoManager(this._db);
  $$LocalExercisesTableTableManager get localExercises =>
      $$LocalExercisesTableTableManager(
        _db.attachedDatabase,
        _db.localExercises,
      );
}
