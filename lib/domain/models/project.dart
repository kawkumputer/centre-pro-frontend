import 'package:centre_educatif/domain/models/user.dart';

enum ProjectStatus {
  DRAFT,
  IN_PROGRESS,
  ON_HOLD,
  COMPLETED,
  CANCELLED;

  String get displayName {
    switch (this) {
      case ProjectStatus.DRAFT:
        return 'Brouillon';
      case ProjectStatus.IN_PROGRESS:
        return 'En cours';
      case ProjectStatus.ON_HOLD:
        return 'En pause';
      case ProjectStatus.COMPLETED:
        return 'Terminé';
      case ProjectStatus.CANCELLED:
        return 'Annulé';
    }
  }

  static ProjectStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return ProjectStatus.DRAFT;
      case 'IN_PROGRESS':
        return ProjectStatus.IN_PROGRESS;
      case 'ON_HOLD':
        return ProjectStatus.ON_HOLD;
      case 'COMPLETED':
        return ProjectStatus.COMPLETED;
      case 'CANCELLED':
        return ProjectStatus.CANCELLED;
      default:
        return ProjectStatus.DRAFT;
    }
  }
}

class Project {
  final int id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? expectedEndDate;
  final ProjectStatus status;
  final double? initialBudget;
  final User owner;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    this.expectedEndDate,
    required this.status,
    this.initialBudget,
    required this.owner,
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      expectedEndDate: json['expectedEndDate'] != null
          ? DateTime.parse(json['expectedEndDate'] as String)
          : null,
      status: ProjectStatus.fromString(json['status'] as String),
      initialBudget: json['initialBudget'] != null
          ? (json['initialBudget'] as num).toDouble()
          : null,
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'expectedEndDate': expectedEndDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'initialBudget': initialBudget,
      'owner': owner.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? expectedEndDate,
    ProjectStatus? status,
    double? initialBudget,
    User? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
