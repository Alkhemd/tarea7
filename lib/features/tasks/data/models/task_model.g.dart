// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskModelImpl _$$TaskModelImplFromJson(Map<String, dynamic> json) =>
    _$TaskModelImpl(
      title: json['title'] as String,
      description: json['body'] as String,
      id: json['id'] as int?,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$$TaskModelImplToJson(_$TaskModelImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.description,
      'id': instance.id,
      'completed': instance.completed,
    };
