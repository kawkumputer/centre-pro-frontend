import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/project_status.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../infrastructure/providers/project_repository_provider.dart';
import '../../widgets/loading_indicator.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectRepository _projectRepository;
  List<Project>? _projects;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectRepository = ProjectRepositoryProvider.of(context);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      setState(() {
        _error = null;
      });

      final projects = await _projectRepository.getProjects();
      setState(() {
        _projects = projects;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _createProject() async {
    final created = await context.push<bool>('/projects/new');
    if (created == true && mounted) {
      _loadProjects();
    }
  }

  Future<void> _viewProjectDetails(Project project) async {
    final updated = await context.push<bool>('/projects/${project.id}');
    if (updated == true && mounted) {
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Projets'),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProjects,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : _projects == null
              ? const Center(child: LoadingIndicator())
              : _projects!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Aucun projet trouvé'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _createProject,
                            child: const Text('Créer un projet'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _projects!.length,
                        itemBuilder: (context, index) {
                          final project = _projects![index];
                          return ProjectCard(
                            project: project,
                            onTap: () => _viewProjectDetails(project),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;

    switch (project.status) {
      case ProjectStatus.DRAFT:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.black87;
        break;
      case ProjectStatus.IN_PROGRESS:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case ProjectStatus.ON_HOLD:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case ProjectStatus.COMPLETED:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case ProjectStatus.CANCELLED:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      project.status.displayName,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Début : ${project.startDate.day}/${project.startDate.month}/${project.startDate.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (project.expectedEndDate != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Fin : ${project.expectedEndDate!.day}/${project.expectedEndDate!.month}/${project.expectedEndDate!.year}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
