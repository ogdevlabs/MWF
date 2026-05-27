// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionModel _$SessionModelFromJson(Map<String, dynamic> json) =>
    _SessionModel(
      id: json['id'] as String,
      programId: json['programId'] as String,
      dayNumber: (json['dayNumber'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      state: $enumDecode(_$SessionStateEnumMap, json['state']),
    );

Map<String, dynamic> _$SessionModelToJson(_SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'programId': instance.programId,
      'dayNumber': instance.dayNumber,
      'title': instance.title,
      'description': instance.description,
      'exerciseCount': instance.exerciseCount,
      'state': _$SessionStateEnumMap[instance.state]!,
    };

const _$SessionStateEnumMap = {
  SessionState.complete: 'complete',
  SessionState.current: 'current',
  SessionState.locked: 'locked',
};

_ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    _ExerciseModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      title: json['title'] as String,
      cueText: json['cueText'] as String?,
      muxPlaybackId: json['muxPlaybackId'] as String?,
      modelAssetUrl: json['modelAssetUrl'] as String?,
      repCount: (json['repCount'] as num?)?.toInt(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      videoVersion: (json['videoVersion'] as num?)?.toInt(),
      localVideoPath: json['localVideoPath'] as String?,
      localModelPath: json['localModelPath'] as String?,
    );

Map<String, dynamic> _$ExerciseModelToJson(_ExerciseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'displayOrder': instance.displayOrder,
      'title': instance.title,
      'cueText': instance.cueText,
      'muxPlaybackId': instance.muxPlaybackId,
      'modelAssetUrl': instance.modelAssetUrl,
      'repCount': instance.repCount,
      'durationSeconds': instance.durationSeconds,
      'videoVersion': instance.videoVersion,
      'localVideoPath': instance.localVideoPath,
      'localModelPath': instance.localModelPath,
    };
