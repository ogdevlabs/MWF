// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  timezone: json['timezone'] as String? ?? 'UTC',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'timezone': instance.timezone,
  'createdAt': instance.createdAt.toIso8601String(),
};
