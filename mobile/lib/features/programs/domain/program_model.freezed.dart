// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgramModel {

 String get id; String get title; String? get description; String get difficulty; int get durationWeeks; String? get thumbnailUrl; DateTime? get publishedAt; String? get enrollmentId; int get currentDay; bool get isSubscribed;
/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramModelCopyWith<ProgramModel> get copyWith => _$ProgramModelCopyWithImpl<ProgramModel>(this as ProgramModel, _$identity);

  /// Serializes this ProgramModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.enrollmentId, enrollmentId) || other.enrollmentId == enrollmentId)&&(identical(other.currentDay, currentDay) || other.currentDay == currentDay)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,difficulty,durationWeeks,thumbnailUrl,publishedAt,enrollmentId,currentDay,isSubscribed);

@override
String toString() {
  return 'ProgramModel(id: $id, title: $title, description: $description, difficulty: $difficulty, durationWeeks: $durationWeeks, thumbnailUrl: $thumbnailUrl, publishedAt: $publishedAt, enrollmentId: $enrollmentId, currentDay: $currentDay, isSubscribed: $isSubscribed)';
}


}

/// @nodoc
abstract mixin class $ProgramModelCopyWith<$Res>  {
  factory $ProgramModelCopyWith(ProgramModel value, $Res Function(ProgramModel) _then) = _$ProgramModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String difficulty, int durationWeeks, String? thumbnailUrl, DateTime? publishedAt, String? enrollmentId, int currentDay, bool isSubscribed
});




}
/// @nodoc
class _$ProgramModelCopyWithImpl<$Res>
    implements $ProgramModelCopyWith<$Res> {
  _$ProgramModelCopyWithImpl(this._self, this._then);

  final ProgramModel _self;
  final $Res Function(ProgramModel) _then;

/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? difficulty = null,Object? durationWeeks = null,Object? thumbnailUrl = freezed,Object? publishedAt = freezed,Object? enrollmentId = freezed,Object? currentDay = null,Object? isSubscribed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enrollmentId: freezed == enrollmentId ? _self.enrollmentId : enrollmentId // ignore: cast_nullable_to_non_nullable
as String?,currentDay: null == currentDay ? _self.currentDay : currentDay // ignore: cast_nullable_to_non_nullable
as int,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgramModel].
extension ProgramModelPatterns on ProgramModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramModel value)  $default,){
final _that = this;
switch (_that) {
case _ProgramModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String difficulty,  int durationWeeks,  String? thumbnailUrl,  DateTime? publishedAt,  String? enrollmentId,  int currentDay,  bool isSubscribed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.difficulty,_that.durationWeeks,_that.thumbnailUrl,_that.publishedAt,_that.enrollmentId,_that.currentDay,_that.isSubscribed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String difficulty,  int durationWeeks,  String? thumbnailUrl,  DateTime? publishedAt,  String? enrollmentId,  int currentDay,  bool isSubscribed)  $default,) {final _that = this;
switch (_that) {
case _ProgramModel():
return $default(_that.id,_that.title,_that.description,_that.difficulty,_that.durationWeeks,_that.thumbnailUrl,_that.publishedAt,_that.enrollmentId,_that.currentDay,_that.isSubscribed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String difficulty,  int durationWeeks,  String? thumbnailUrl,  DateTime? publishedAt,  String? enrollmentId,  int currentDay,  bool isSubscribed)?  $default,) {final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.difficulty,_that.durationWeeks,_that.thumbnailUrl,_that.publishedAt,_that.enrollmentId,_that.currentDay,_that.isSubscribed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgramModel implements ProgramModel {
  const _ProgramModel({required this.id, required this.title, this.description, required this.difficulty, required this.durationWeeks, this.thumbnailUrl, this.publishedAt, this.enrollmentId, this.currentDay = 1, this.isSubscribed = false});
  factory _ProgramModel.fromJson(Map<String, dynamic> json) => _$ProgramModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String difficulty;
@override final  int durationWeeks;
@override final  String? thumbnailUrl;
@override final  DateTime? publishedAt;
@override final  String? enrollmentId;
@override@JsonKey() final  int currentDay;
@override@JsonKey() final  bool isSubscribed;

/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramModelCopyWith<_ProgramModel> get copyWith => __$ProgramModelCopyWithImpl<_ProgramModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgramModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.enrollmentId, enrollmentId) || other.enrollmentId == enrollmentId)&&(identical(other.currentDay, currentDay) || other.currentDay == currentDay)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,difficulty,durationWeeks,thumbnailUrl,publishedAt,enrollmentId,currentDay,isSubscribed);

@override
String toString() {
  return 'ProgramModel(id: $id, title: $title, description: $description, difficulty: $difficulty, durationWeeks: $durationWeeks, thumbnailUrl: $thumbnailUrl, publishedAt: $publishedAt, enrollmentId: $enrollmentId, currentDay: $currentDay, isSubscribed: $isSubscribed)';
}


}

/// @nodoc
abstract mixin class _$ProgramModelCopyWith<$Res> implements $ProgramModelCopyWith<$Res> {
  factory _$ProgramModelCopyWith(_ProgramModel value, $Res Function(_ProgramModel) _then) = __$ProgramModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String difficulty, int durationWeeks, String? thumbnailUrl, DateTime? publishedAt, String? enrollmentId, int currentDay, bool isSubscribed
});




}
/// @nodoc
class __$ProgramModelCopyWithImpl<$Res>
    implements _$ProgramModelCopyWith<$Res> {
  __$ProgramModelCopyWithImpl(this._self, this._then);

  final _ProgramModel _self;
  final $Res Function(_ProgramModel) _then;

/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? difficulty = null,Object? durationWeeks = null,Object? thumbnailUrl = freezed,Object? publishedAt = freezed,Object? enrollmentId = freezed,Object? currentDay = null,Object? isSubscribed = null,}) {
  return _then(_ProgramModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enrollmentId: freezed == enrollmentId ? _self.enrollmentId : enrollmentId // ignore: cast_nullable_to_non_nullable
as String?,currentDay: null == currentDay ? _self.currentDay : currentDay // ignore: cast_nullable_to_non_nullable
as int,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
