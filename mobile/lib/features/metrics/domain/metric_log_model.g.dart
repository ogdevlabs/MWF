// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MetricLog _$MetricLogFromJson(Map<String, dynamic> json) => _MetricLog(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  metricType: json['metricType'] as String,
  metricSubtype: json['metricSubtype'] as String?,
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  loggedAt: DateTime.parse(json['loggedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MetricLogToJson(_MetricLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'metricType': instance.metricType,
      'metricSubtype': instance.metricSubtype,
      'value': instance.value,
      'unit': instance.unit,
      'loggedAt': instance.loggedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
