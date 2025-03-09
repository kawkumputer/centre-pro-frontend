import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _projectsKey = 'projects';

  ProjectRepositoryImpl(this._dio, this._prefs) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
  }

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
        '/api/projects',
        data: jsonEncode({
          'name': name,
          'description': description,
          'startDate': startDate.toIso8601String().split('T')[0],
          'expectedEndDate': expectedEndDate?.toIso8601String().split('T')[0],
          'status': status.toString().split('.').last,
          'initialBudget': initialBudget,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Erreur lors de la création du projet: ${response.statusCode}');
      }

      final project = Project.fromJson(response.data);

      // Mettre à jour le cache local
      await _updateProjectInCache(project);

      return project;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la création du projet: ${e.toString()}');
    }
  }

  @override
  Future<Project> getProject(int id) async {
    try {
      // Essayer d'abord de récupérer depuis le cache
      final cachedProject = await _getProjectFromCache(id);
      if (cachedProject != null) {
        return cachedProject;
      }

      final response = await _dio.get(
        '/api/projects/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la récupération du projet: ${response.statusCode}');
      }

      final project = Project.fromJson(response.data);

      // Mettre à jour le cache
      await _updateProjectInCache(project);

      return project;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du projet: ${e.toString()}');
    }
  }

  @override
  Future<List<Project>> getProjects({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/api/projects',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la récupération des projets: ${response.statusCode}');
      }

      final List<Project> projects = (response.data['content'] as List)
          .map((json) => Project.fromJson(json))
          .toList();

      // Mettre à jour le cache pour tous les projets
      await _updateProjectsCache(projects);

      return projects;
    } on DioException catch (e) {
      // En cas d'erreur réseau, essayer de récupérer depuis le cache
      if (e.type == DioExceptionType.connectionError) {
        developer.log('Erreur réseau, utilisation du cache', name: 'Projects');
        return _getAllProjectsFromCache();
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des projets: ${e.toString()}');
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
        '/api/projects/$id',
        data: jsonEncode({
          'name': name,
          'description': description,
          'startDate': startDate.toIso8601String().split('T')[0],
          'expectedEndDate': expectedEndDate?.toIso8601String().split('T')[0],
          'status': status.toString().split('.').last,
          'initialBudget': initialBudget,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du projet: ${response.statusCode}');
      }

      final project = Project.fromJson(response.data);

      // Mettre à jour le cache
      await _updateProjectInCache(project);

      return project;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du projet: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      final response = await _dio.delete(
        '/api/projects/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du projet: ${response.statusCode}');
      }

      // Supprimer du cache
      await _removeProjectFromCache(id);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du projet: ${e.toString()}');
    }
  }

  Future<void> _updateProjectInCache(Project project) async {
    final projectsJson = _prefs.getString(_projectsKey);
    Map<String, dynamic> projectsMap;
    if (projectsJson != null) {
      projectsMap = jsonDecode(projectsJson);
    } else {
      projectsMap = {};
    }

    projectsMap[project.id.toString()] = project.toJson();
    await _prefs.setString(_projectsKey, jsonEncode(projectsMap));
  }

  Future<void> _updateProjectsCache(List<Project> projects) async {
    final projectsMap = {
      for (var project in projects) project.id.toString(): project.toJson()
    };
    await _prefs.setString(_projectsKey, jsonEncode(projectsMap));
  }

  Future<Project?> _getProjectFromCache(int id) async {
    final projectsJson = _prefs.getString(_projectsKey);
    if (projectsJson != null) {
      final projectsMap = jsonDecode(projectsJson) as Map<String, dynamic>;
      final projectJson = projectsMap[id.toString()];
      if (projectJson != null) {
        return Project.fromJson(projectJson);
      }
    }
    return null;
  }

  Future<List<Project>> _getAllProjectsFromCache() async {
    final projectsJson = _prefs.getString(_projectsKey);
    if (projectsJson != null) {
      final projectsMap = jsonDecode(projectsJson) as Map<String, dynamic>;
      return projectsMap.values
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> _removeProjectFromCache(int id) async {
    final projectsJson = _prefs.getString(_projectsKey);
    if (projectsJson != null) {
      final projectsMap = jsonDecode(projectsJson) as Map<String, dynamic>;
      projectsMap.remove(id.toString());
      await _prefs.setString(_projectsKey, jsonEncode(projectsMap));
    }
  }

  Exception _handleDioError(DioException error) {
    final response = error.response;
    if (response != null) {
      final data = response.data;
      if (data != null && data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null) {
          return Exception(message);
        }
      }
      return Exception('Erreur ${response.statusCode}: ${response.statusMessage}');
    }
    return Exception('Erreur de connexion: ${error.message}');
  }
}
