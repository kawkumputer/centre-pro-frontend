import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_status.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  static const String _projectsCacheKey = 'cached_projects';
  final Dio _dio;
  final SharedPreferences _prefs;

  ProjectRepositoryImpl(this._dio, this._prefs);

  @override
  Future<Project> createProject({
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? expectedEndDate,
    required ProjectStatus status,
    double? initialBudget,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.projects,
        data: jsonEncode({
          'name': name,
          'description': description,
          'startDate': startDate.toIso8601String().split('T')[0],
          'expectedEndDate': expectedEndDate?.toIso8601String().split('T')[0],
          'status': status.toString().split('.').last,
          'initialBudget': initialBudget,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Erreur lors de la création du projet: ${response.statusCode}');
      }

      final project = Project.fromJson(response.data);
      await _updateProjectInCache(project);
      return project;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Données invalides : ${e.response?.data['message']}');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Non autorisé. Veuillez vous reconnecter.');
        }
        if (e.response?.statusCode == 403) {
          throw Exception("Vous n'avez pas les permissions nécessaires.");
        }
      }
      developer.log('Erreur lors de la création du projet : ${e.toString()}');
      throw Exception('Erreur lors de la création du projet : ${e.toString()}');
    }
  }

  @override
  Future<Project> getProject(int id) async {
    try {
      // Essayer d'abord de récupérer depuis le cache
      final cachedProjects = await _getCachedProjects();
      final cachedProject = cachedProjects.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Projet non trouvé dans le cache'),
      );

      // En mode hors-ligne, retourner le projet du cache
      if (!await _hasInternetConnection()) {
        return cachedProject;
      }

      // Si en ligne, récupérer la dernière version
      final response = await _dio.get(ApiConfig.project(id));

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la récupération du projet: ${response.statusCode}');
      }

      final project = Project.fromJson(response.data);
      await _updateProjectInCache(project);
      return project;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Projet non trouvé');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Non autorisé. Veuillez vous reconnecter.');
        }
        if (e.response?.statusCode == 403) {
          throw Exception("Vous n'avez pas les permissions nécessaires.");
        }
      }
      developer.log('Erreur lors de la récupération du projet : ${e.toString()}');
      throw Exception('Erreur lors de la récupération du projet : ${e.toString()}');
    }
  }

  @override
  Future<List<Project>> getProjects() async {
    try {
      // En mode hors-ligne, retourner les projets du cache
      if (!await _hasInternetConnection()) {
        return await _getCachedProjects();
      }

      final response = await _dio.get(ApiConfig.projects);

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la récupération des projets: ${response.statusCode}');
      }

      // Extraire les projets du champ 'content' de la réponse paginée
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> projectsJson = responseData['content'] as List<dynamic>;
      final projects = projectsJson.map((json) => Project.fromJson(json)).toList();

      // Mettre à jour le cache
      await _prefs.setString(_projectsCacheKey, Project.listToJsonString(projects));

      return projects;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Non autorisé. Veuillez vous reconnecter.');
        }
        if (e.response?.statusCode == 403) {
          throw Exception("Vous n'avez pas les permissions nécessaires.");
        }
      }
      developer.log('Erreur lors de la récupération des projets : ${e.toString()}');
      throw Exception('Erreur lors de la récupération des projets : ${e.toString()}');
    }
  }

  @override
  Future<Project> updateProject(
    int id, {
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? expectedEndDate,
    required ProjectStatus status,
    double? initialBudget,
  }) async {
    try {
      final response = await _dio.put(
        ApiConfig.project(id),
        data: jsonEncode({
          'name': name,
          'description': description,
          'startDate': startDate.toIso8601String().split('T')[0],
          'expectedEndDate': expectedEndDate?.toIso8601String().split('T')[0],
          'status': status.toString().split('.').last,
          'initialBudget': initialBudget,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du projet: ${response.statusCode}');
      }

      final project = Project.fromJson(response.data);
      await _updateProjectInCache(project);
      return project;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Données invalides : ${e.response?.data['message']}');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Non autorisé. Veuillez vous reconnecter.');
        }
        if (e.response?.statusCode == 403) {
          throw Exception("Vous n'avez pas les permissions nécessaires.");
        }
        if (e.response?.statusCode == 404) {
          throw Exception('Projet non trouvé');
        }
      }
      developer.log('Erreur lors de la mise à jour du projet : ${e.toString()}');
      throw Exception('Erreur lors de la mise à jour du projet : ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      final response = await _dio.delete(ApiConfig.project(id));

      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du projet: ${response.statusCode}');
      }

      // Mettre à jour le cache
      final projects = await _getCachedProjects();
      projects.removeWhere((p) => p.id == id);
      await _prefs.setString(_projectsCacheKey, Project.listToJsonString(projects));
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Non autorisé. Veuillez vous reconnecter.');
        }
        if (e.response?.statusCode == 403) {
          throw Exception("Vous n'avez pas les permissions nécessaires.");
        }
        if (e.response?.statusCode == 404) {
          throw Exception('Projet non trouvé');
        }
      }
      developer.log('Erreur lors de la suppression du projet : ${e.toString()}');
      throw Exception('Erreur lors de la suppression du projet : ${e.toString()}');
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      // Vérifier la connexion en utilisant un endpoint valide
      final response = await _dio.head(ApiConfig.projects);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Project>> _getCachedProjects() async {
    final projectsStr = _prefs.getString(_projectsCacheKey);
    if (projectsStr == null) {
      return [];
    }
    return Project.listFromJsonString(projectsStr);
  }

  Future<void> _updateProjectInCache(Project project) async {
    final projects = await _getCachedProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(_projectsCacheKey, Project.listToJsonString(projects));
  }
}
