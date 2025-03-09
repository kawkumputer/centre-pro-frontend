import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:centre_educatif/domain/models/user.dart';
import 'project_status.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? expectedEndDate;
  final ProjectStatus status;
  final double? initialBudget;
  final User owner;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    this.expectedEndDate,
    required this.status,
    this.initialBudget,
    required this.owner,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  // Pour le stockage local
  static List<Project> listFromJsonString(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Project.fromJson(json)).toList();
  }

  static String listToJsonString(List<Project> projects) {
    final List<Map<String, dynamic>> jsonList = projects.map((p) => p.toJson()).toList();
    return json.encode(jsonList);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          startDate == other.startDate &&
          expectedEndDate == other.expectedEndDate &&
          status == other.status &&
          initialBudget == other.initialBudget &&
          owner == other.owner;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      startDate.hashCode ^
      expectedEndDate.hashCode ^
      status.hashCode ^
      initialBudget.hashCode ^
      owner.hashCode;

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? expectedEndDate,
    ProjectStatus? status,
    double? initialBudget,
    User? owner,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      status: status ?? this.status,
      initialBudget: initialBudget ?? this.initialBudget,
      owner: owner ?? this.owner,
    );
  }
}
