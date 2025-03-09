import '../models/project.dart';
import '../models/project_status.dart';

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

  Future<List<Project>> getProjects();

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
