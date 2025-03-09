// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      expectedEndDate: json['expectedEndDate'] == null
          ? null
          : DateTime.parse(json['expectedEndDate'] as String),
      status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
      initialBudget: (json['initialBudget'] as num?)?.toDouble(),
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'expectedEndDate': instance.expectedEndDate?.toIso8601String(),
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'initialBudget': instance.initialBudget,
      'owner': instance.owner,
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.DRAFT: 'DRAFT',
  ProjectStatus.IN_PROGRESS: 'IN_PROGRESS',
  ProjectStatus.ON_HOLD: 'ON_HOLD',
  ProjectStatus.COMPLETED: 'COMPLETED',
  ProjectStatus.CANCELLED: 'CANCELLED',
};
