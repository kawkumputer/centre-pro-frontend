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
    return ProjectStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value,
      orElse: () => ProjectStatus.DRAFT,
    );
  }
}
