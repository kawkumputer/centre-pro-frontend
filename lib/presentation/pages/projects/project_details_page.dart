import 'package:flutter/material.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/project_status.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../infrastructure/providers/project_repository_provider.dart';
import '../../widgets/loading_indicator.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late final ProjectRepository _projectRepository;
  bool _isLoading = false;
  String? _error;
  Project? _project;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectRepository = ProjectRepositoryProvider.of(context);
    _loadProject();
  }

  Future<void> _loadProject() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final project = await _projectRepository.getProject(int.parse(widget.projectId));
      setState(() {
        _project = project;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce projet ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && _project != null) {
      try {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        await _projectRepository.deleteProject(_project!.id);

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du projet'),
        ),
        body: const LoadingIndicator(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du projet'),
        ),
        body: Center(
          child: Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ),
        ),
      );
    }

    if (_project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du projet'),
        ),
        body: const Center(
          child: Text('Projet non trouvé'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du projet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.pushNamed(
                context,
                '/projects/edit/${_project!.id}',
              );
              if (updated == true) {
                _loadProject();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProject,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _project!.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_project!.status),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            _project!.status.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (_project!.description != null) ...[
                      const SizedBox(height: 16.0),
                      Text(
                        _project!.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date de début'),
                              const SizedBox(height: 4.0),
                              Text(
                                '${_project!.startDate.day}/${_project!.startDate.month}/${_project!.startDate.year}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        if (_project!.expectedEndDate != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date de fin prévue'),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${_project!.expectedEndDate!.day}/${_project!.expectedEndDate!.month}/${_project!.expectedEndDate!.year}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (_project!.initialBudget != null) ...[
                      const SizedBox(height: 16.0),
                      const Text('Budget initial'),
                      const SizedBox(height: 4.0),
                      Text(
                        '${_project!.initialBudget!.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.DRAFT:
        return Colors.grey;
      case ProjectStatus.IN_PROGRESS:
        return Colors.blue;
      case ProjectStatus.ON_HOLD:
        return Colors.orange;
      case ProjectStatus.COMPLETED:
        return Colors.green;
      case ProjectStatus.CANCELLED:
        return Colors.red;
    }
  }
}
