// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProgramModel _$ProgramModelFromJson(Map<String, dynamic> json) =>
    _ProgramModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String,
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      enrollmentId: json['enrollmentId'] as String?,
      currentDay: (json['currentDay'] as num?)?.toInt() ?? 1,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
    );

Map<String, dynamic> _$ProgramModelToJson(_ProgramModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'difficulty': instance.difficulty,
      'durationWeeks': instance.durationWeeks,
      'thumbnailUrl': instance.thumbnailUrl,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'enrollmentId': instance.enrollmentId,
      'currentDay': instance.currentDay,
      'isSubscribed': instance.isSubscribed,
    };
