// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metric_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetricLog {

 String get id; String get studentId; String get metricType; String? get metricSubtype; double get value; String get unit; DateTime get loggedAt; DateTime get createdAt;
/// Create a copy of MetricLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetricLogCopyWith<MetricLog> get copyWith => _$MetricLogCopyWithImpl<MetricLog>(this as MetricLog, _$identity);

  /// Serializes this MetricLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetricLog&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.metricSubtype, metricSubtype) || other.metricSubtype == metricSubtype)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,metricType,metricSubtype,value,unit,loggedAt,createdAt);

@override
String toString() {
  return 'MetricLog(id: $id, studentId: $studentId, metricType: $metricType, metricSubtype: $metricSubtype, value: $value, unit: $unit, loggedAt: $loggedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MetricLogCopyWith<$Res>  {
  factory $MetricLogCopyWith(MetricLog value, $Res Function(MetricLog) _then) = _$MetricLogCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String metricType, String? metricSubtype, double value, String unit, DateTime loggedAt, DateTime createdAt
});




}
/// @nodoc
class _$MetricLogCopyWithImpl<$Res>
    implements $MetricLogCopyWith<$Res> {
  _$MetricLogCopyWithImpl(this._self, this._then);

  final MetricLog _self;
  final $Res Function(MetricLog) _then;

/// Create a copy of MetricLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? metricType = null,Object? metricSubtype = freezed,Object? value = null,Object? unit = null,Object? loggedAt = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as String,metricSubtype: freezed == metricSubtype ? _self.metricSubtype : metricSubtype // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,loggedAt: null == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MetricLog].
extension MetricLogPatterns on MetricLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetricLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetricLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetricLog value)  $default,){
final _that = this;
switch (_that) {
case _MetricLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetricLog value)?  $default,){
final _that = this;
switch (_that) {
case _MetricLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String metricType,  String? metricSubtype,  double value,  String unit,  DateTime loggedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetricLog() when $default != null:
return $default(_that.id,_that.studentId,_that.metricType,_that.metricSubtype,_that.value,_that.unit,_that.loggedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String metricType,  String? metricSubtype,  double value,  String unit,  DateTime loggedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MetricLog():
return $default(_that.id,_that.studentId,_that.metricType,_that.metricSubtype,_that.value,_that.unit,_that.loggedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String metricType,  String? metricSubtype,  double value,  String unit,  DateTime loggedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MetricLog() when $default != null:
return $default(_that.id,_that.studentId,_that.metricType,_that.metricSubtype,_that.value,_that.unit,_that.loggedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetricLog implements MetricLog {
  const _MetricLog({required this.id, required this.studentId, required this.metricType, this.metricSubtype, required this.value, required this.unit, required this.loggedAt, required this.createdAt});
  factory _MetricLog.fromJson(Map<String, dynamic> json) => _$MetricLogFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String metricType;
@override final  String? metricSubtype;
@override final  double value;
@override final  String unit;
@override final  DateTime loggedAt;
@override final  DateTime createdAt;

/// Create a copy of MetricLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetricLogCopyWith<_MetricLog> get copyWith => __$MetricLogCopyWithImpl<_MetricLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetricLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetricLog&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.metricSubtype, metricSubtype) || other.metricSubtype == metricSubtype)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,metricType,metricSubtype,value,unit,loggedAt,createdAt);

@override
String toString() {
  return 'MetricLog(id: $id, studentId: $studentId, metricType: $metricType, metricSubtype: $metricSubtype, value: $value, unit: $unit, loggedAt: $loggedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MetricLogCopyWith<$Res> implements $MetricLogCopyWith<$Res> {
  factory _$MetricLogCopyWith(_MetricLog value, $Res Function(_MetricLog) _then) = __$MetricLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String metricType, String? metricSubtype, double value, String unit, DateTime loggedAt, DateTime createdAt
});




}
/// @nodoc
class __$MetricLogCopyWithImpl<$Res>
    implements _$MetricLogCopyWith<$Res> {
  __$MetricLogCopyWithImpl(this._self, this._then);

  final _MetricLog _self;
  final $Res Function(_MetricLog) _then;

/// Create a copy of MetricLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? metricType = null,Object? metricSubtype = freezed,Object? value = null,Object? unit = null,Object? loggedAt = null,Object? createdAt = null,}) {
  return _then(_MetricLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as String,metricSubtype: freezed == metricSubtype ? _self.metricSubtype : metricSubtype // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,loggedAt: null == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
