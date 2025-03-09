import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/project_repository.dart';
import '../repositories/project_repository_impl.dart';

class ProjectRepositoryProvider extends InheritedWidget {
  final ProjectRepository repository;

  const ProjectRepositoryProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  static ProjectRepository of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ProjectRepositoryProvider>();
    if (provider == null) {
      throw Exception('ProjectRepositoryProvider not found in widget tree');
    }
    return provider.repository;
  }

  @override
  bool updateShouldNotify(ProjectRepositoryProvider oldWidget) {
    return repository != oldWidget.repository;
  }

  static Future<ProjectRepositoryProvider> create({
    required Widget child,
    required Dio dio,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return ProjectRepositoryProvider(
      repository: ProjectRepositoryImpl(dio, prefs),
      child: child,
    );
  }
}
