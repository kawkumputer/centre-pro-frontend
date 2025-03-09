import '../models/project.dart';

abstract class ProjectRepository {
  Future<Project> createProject({
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? expectedEndDate,
    required ProjectStatus status,
    double? initialBudget,
  });

  Future<Project> getProject(int id);

  Future<List<Project>> getProjects({int page = 0, int size = 20});

  Future<Project> updateProject(
    int id, {
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? expectedEndDate,
    required ProjectStatus status,
    double? initialBudget,
  });

  Future<void> deleteProject(int id);
}
