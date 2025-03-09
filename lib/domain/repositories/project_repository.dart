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

  Future<Project> getProject(String id);

  Future<List<Project>> getProjects();

  Future<Project> updateProject(
    String id, {
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? expectedEndDate,
    required ProjectStatus status,
    double? initialBudget,
  });

  Future<void> deleteProject(String id);
}
