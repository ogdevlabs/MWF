// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionModel {

 String get id; String get programId; int get dayNumber; String get title; String? get description; int get exerciseCount; SessionState get state;
/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionModelCopyWith<SessionModel> get copyWith => _$SessionModelCopyWithImpl<SessionModel>(this as SessionModel, _$identity);

  /// Serializes this SessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.dayNumber, dayNumber) || other.dayNumber == dayNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,programId,dayNumber,title,description,exerciseCount,state);

@override
String toString() {
  return 'SessionModel(id: $id, programId: $programId, dayNumber: $dayNumber, title: $title, description: $description, exerciseCount: $exerciseCount, state: $state)';
}


}

/// @nodoc
abstract mixin class $SessionModelCopyWith<$Res>  {
  factory $SessionModelCopyWith(SessionModel value, $Res Function(SessionModel) _then) = _$SessionModelCopyWithImpl;
@useResult
$Res call({
 String id, String programId, int dayNumber, String title, String? description, int exerciseCount, SessionState state
});




}
/// @nodoc
class _$SessionModelCopyWithImpl<$Res>
    implements $SessionModelCopyWith<$Res> {
  _$SessionModelCopyWithImpl(this._self, this._then);

  final SessionModel _self;
  final $Res Function(SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? programId = null,Object? dayNumber = null,Object? title = null,Object? description = freezed,Object? exerciseCount = null,Object? state = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,dayNumber: null == dayNumber ? _self.dayNumber : dayNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SessionState,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionModel].
extension SessionModelPatterns on SessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String programId,  int dayNumber,  String title,  String? description,  int exerciseCount,  SessionState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.id,_that.programId,_that.dayNumber,_that.title,_that.description,_that.exerciseCount,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String programId,  int dayNumber,  String title,  String? description,  int exerciseCount,  SessionState state)  $default,) {final _that = this;
switch (_that) {
case _SessionModel():
return $default(_that.id,_that.programId,_that.dayNumber,_that.title,_that.description,_that.exerciseCount,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String programId,  int dayNumber,  String title,  String? description,  int exerciseCount,  SessionState state)?  $default,) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.id,_that.programId,_that.dayNumber,_that.title,_that.description,_that.exerciseCount,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionModel implements SessionModel {
  const _SessionModel({required this.id, required this.programId, required this.dayNumber, required this.title, this.description, required this.exerciseCount, required this.state});
  factory _SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

@override final  String id;
@override final  String programId;
@override final  int dayNumber;
@override final  String title;
@override final  String? description;
@override final  int exerciseCount;
@override final  SessionState state;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionModelCopyWith<_SessionModel> get copyWith => __$SessionModelCopyWithImpl<_SessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.dayNumber, dayNumber) || other.dayNumber == dayNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,programId,dayNumber,title,description,exerciseCount,state);

@override
String toString() {
  return 'SessionModel(id: $id, programId: $programId, dayNumber: $dayNumber, title: $title, description: $description, exerciseCount: $exerciseCount, state: $state)';
}


}

/// @nodoc
abstract mixin class _$SessionModelCopyWith<$Res> implements $SessionModelCopyWith<$Res> {
  factory _$SessionModelCopyWith(_SessionModel value, $Res Function(_SessionModel) _then) = __$SessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String programId, int dayNumber, String title, String? description, int exerciseCount, SessionState state
});




}
/// @nodoc
class __$SessionModelCopyWithImpl<$Res>
    implements _$SessionModelCopyWith<$Res> {
  __$SessionModelCopyWithImpl(this._self, this._then);

  final _SessionModel _self;
  final $Res Function(_SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? programId = null,Object? dayNumber = null,Object? title = null,Object? description = freezed,Object? exerciseCount = null,Object? state = null,}) {
  return _then(_SessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,dayNumber: null == dayNumber ? _self.dayNumber : dayNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SessionState,
  ));
}


}


/// @nodoc
mixin _$ExerciseModel {

 String get id; String get sessionId; int get displayOrder; String get title; String? get cueText; String? get muxPlaybackId; String? get modelAssetUrl; int? get repCount; int? get durationSeconds; int? get videoVersion; String? get localVideoPath; String? get localModelPath;
/// Create a copy of ExerciseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseModelCopyWith<ExerciseModel> get copyWith => _$ExerciseModelCopyWithImpl<ExerciseModel>(this as ExerciseModel, _$identity);

  /// Serializes this ExerciseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.title, title) || other.title == title)&&(identical(other.cueText, cueText) || other.cueText == cueText)&&(identical(other.muxPlaybackId, muxPlaybackId) || other.muxPlaybackId == muxPlaybackId)&&(identical(other.modelAssetUrl, modelAssetUrl) || other.modelAssetUrl == modelAssetUrl)&&(identical(other.repCount, repCount) || other.repCount == repCount)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.videoVersion, videoVersion) || other.videoVersion == videoVersion)&&(identical(other.localVideoPath, localVideoPath) || other.localVideoPath == localVideoPath)&&(identical(other.localModelPath, localModelPath) || other.localModelPath == localModelPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,displayOrder,title,cueText,muxPlaybackId,modelAssetUrl,repCount,durationSeconds,videoVersion,localVideoPath,localModelPath);

@override
String toString() {
  return 'ExerciseModel(id: $id, sessionId: $sessionId, displayOrder: $displayOrder, title: $title, cueText: $cueText, muxPlaybackId: $muxPlaybackId, modelAssetUrl: $modelAssetUrl, repCount: $repCount, durationSeconds: $durationSeconds, videoVersion: $videoVersion, localVideoPath: $localVideoPath, localModelPath: $localModelPath)';
}


}

/// @nodoc
abstract mixin class $ExerciseModelCopyWith<$Res>  {
  factory $ExerciseModelCopyWith(ExerciseModel value, $Res Function(ExerciseModel) _then) = _$ExerciseModelCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, int displayOrder, String title, String? cueText, String? muxPlaybackId, String? modelAssetUrl, int? repCount, int? durationSeconds, int? videoVersion, String? localVideoPath, String? localModelPath
});




}
/// @nodoc
class _$ExerciseModelCopyWithImpl<$Res>
    implements $ExerciseModelCopyWith<$Res> {
  _$ExerciseModelCopyWithImpl(this._self, this._then);

  final ExerciseModel _self;
  final $Res Function(ExerciseModel) _then;

/// Create a copy of ExerciseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? displayOrder = null,Object? title = null,Object? cueText = freezed,Object? muxPlaybackId = freezed,Object? modelAssetUrl = freezed,Object? repCount = freezed,Object? durationSeconds = freezed,Object? videoVersion = freezed,Object? localVideoPath = freezed,Object? localModelPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cueText: freezed == cueText ? _self.cueText : cueText // ignore: cast_nullable_to_non_nullable
as String?,muxPlaybackId: freezed == muxPlaybackId ? _self.muxPlaybackId : muxPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,modelAssetUrl: freezed == modelAssetUrl ? _self.modelAssetUrl : modelAssetUrl // ignore: cast_nullable_to_non_nullable
as String?,repCount: freezed == repCount ? _self.repCount : repCount // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,videoVersion: freezed == videoVersion ? _self.videoVersion : videoVersion // ignore: cast_nullable_to_non_nullable
as int?,localVideoPath: freezed == localVideoPath ? _self.localVideoPath : localVideoPath // ignore: cast_nullable_to_non_nullable
as String?,localModelPath: freezed == localModelPath ? _self.localModelPath : localModelPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseModel].
extension ExerciseModelPatterns on ExerciseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseModel value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  int displayOrder,  String title,  String? cueText,  String? muxPlaybackId,  String? modelAssetUrl,  int? repCount,  int? durationSeconds,  int? videoVersion,  String? localVideoPath,  String? localModelPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseModel() when $default != null:
return $default(_that.id,_that.sessionId,_that.displayOrder,_that.title,_that.cueText,_that.muxPlaybackId,_that.modelAssetUrl,_that.repCount,_that.durationSeconds,_that.videoVersion,_that.localVideoPath,_that.localModelPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  int displayOrder,  String title,  String? cueText,  String? muxPlaybackId,  String? modelAssetUrl,  int? repCount,  int? durationSeconds,  int? videoVersion,  String? localVideoPath,  String? localModelPath)  $default,) {final _that = this;
switch (_that) {
case _ExerciseModel():
return $default(_that.id,_that.sessionId,_that.displayOrder,_that.title,_that.cueText,_that.muxPlaybackId,_that.modelAssetUrl,_that.repCount,_that.durationSeconds,_that.videoVersion,_that.localVideoPath,_that.localModelPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  int displayOrder,  String title,  String? cueText,  String? muxPlaybackId,  String? modelAssetUrl,  int? repCount,  int? durationSeconds,  int? videoVersion,  String? localVideoPath,  String? localModelPath)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseModel() when $default != null:
return $default(_that.id,_that.sessionId,_that.displayOrder,_that.title,_that.cueText,_that.muxPlaybackId,_that.modelAssetUrl,_that.repCount,_that.durationSeconds,_that.videoVersion,_that.localVideoPath,_that.localModelPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseModel implements ExerciseModel {
  const _ExerciseModel({required this.id, required this.sessionId, required this.displayOrder, required this.title, this.cueText, this.muxPlaybackId, this.modelAssetUrl, this.repCount, this.durationSeconds, this.videoVersion, this.localVideoPath, this.localModelPath});
  factory _ExerciseModel.fromJson(Map<String, dynamic> json) => _$ExerciseModelFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  int displayOrder;
@override final  String title;
@override final  String? cueText;
@override final  String? muxPlaybackId;
@override final  String? modelAssetUrl;
@override final  int? repCount;
@override final  int? durationSeconds;
@override final  int? videoVersion;
@override final  String? localVideoPath;
@override final  String? localModelPath;

/// Create a copy of ExerciseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseModelCopyWith<_ExerciseModel> get copyWith => __$ExerciseModelCopyWithImpl<_ExerciseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.title, title) || other.title == title)&&(identical(other.cueText, cueText) || other.cueText == cueText)&&(identical(other.muxPlaybackId, muxPlaybackId) || other.muxPlaybackId == muxPlaybackId)&&(identical(other.modelAssetUrl, modelAssetUrl) || other.modelAssetUrl == modelAssetUrl)&&(identical(other.repCount, repCount) || other.repCount == repCount)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.videoVersion, videoVersion) || other.videoVersion == videoVersion)&&(identical(other.localVideoPath, localVideoPath) || other.localVideoPath == localVideoPath)&&(identical(other.localModelPath, localModelPath) || other.localModelPath == localModelPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,displayOrder,title,cueText,muxPlaybackId,modelAssetUrl,repCount,durationSeconds,videoVersion,localVideoPath,localModelPath);

@override
String toString() {
  return 'ExerciseModel(id: $id, sessionId: $sessionId, displayOrder: $displayOrder, title: $title, cueText: $cueText, muxPlaybackId: $muxPlaybackId, modelAssetUrl: $modelAssetUrl, repCount: $repCount, durationSeconds: $durationSeconds, videoVersion: $videoVersion, localVideoPath: $localVideoPath, localModelPath: $localModelPath)';
}


}

/// @nodoc
abstract mixin class _$ExerciseModelCopyWith<$Res> implements $ExerciseModelCopyWith<$Res> {
  factory _$ExerciseModelCopyWith(_ExerciseModel value, $Res Function(_ExerciseModel) _then) = __$ExerciseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, int displayOrder, String title, String? cueText, String? muxPlaybackId, String? modelAssetUrl, int? repCount, int? durationSeconds, int? videoVersion, String? localVideoPath, String? localModelPath
});




}
/// @nodoc
class __$ExerciseModelCopyWithImpl<$Res>
    implements _$ExerciseModelCopyWith<$Res> {
  __$ExerciseModelCopyWithImpl(this._self, this._then);

  final _ExerciseModel _self;
  final $Res Function(_ExerciseModel) _then;

/// Create a copy of ExerciseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? displayOrder = null,Object? title = null,Object? cueText = freezed,Object? muxPlaybackId = freezed,Object? modelAssetUrl = freezed,Object? repCount = freezed,Object? durationSeconds = freezed,Object? videoVersion = freezed,Object? localVideoPath = freezed,Object? localModelPath = freezed,}) {
  return _then(_ExerciseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cueText: freezed == cueText ? _self.cueText : cueText // ignore: cast_nullable_to_non_nullable
as String?,muxPlaybackId: freezed == muxPlaybackId ? _self.muxPlaybackId : muxPlaybackId // ignore: cast_nullable_to_non_nullable
as String?,modelAssetUrl: freezed == modelAssetUrl ? _self.modelAssetUrl : modelAssetUrl // ignore: cast_nullable_to_non_nullable
as String?,repCount: freezed == repCount ? _self.repCount : repCount // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,videoVersion: freezed == videoVersion ? _self.videoVersion : videoVersion // ignore: cast_nullable_to_non_nullable
as int?,localVideoPath: freezed == localVideoPath ? _self.localVideoPath : localVideoPath // ignore: cast_nullable_to_non_nullable
as String?,localModelPath: freezed == localModelPath ? _self.localModelPath : localModelPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
