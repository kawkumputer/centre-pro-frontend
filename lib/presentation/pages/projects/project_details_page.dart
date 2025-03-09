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
  bool _isLoading = true;
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

      final project = await _projectRepository.getProject(widget.projectId);
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
            child: Text(
              'Supprimer',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Détails du projet'),
        actions: _project == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/projects/${_project!.id}/edit',
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
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error != null
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
                        onPressed: _loadProject,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _project == null
                  ? const Center(
                      child: Text('Projet non trouvé'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _project!.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          if (_project!.description != null) ...[
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(_project!.description!),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Statut',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(_project!.status.displayName),
                            backgroundColor: _getStatusColor(_project!.status),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Dates',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text('Date de début'),
                            subtitle: Text(
                              '${_project!.startDate.day}/${_project!.startDate.month}/${_project!.startDate.year}',
                            ),
                          ),
                          if (_project!.expectedEndDate != null)
                            ListTile(
                              title: const Text('Date de fin prévue'),
                              subtitle: Text(
                                '${_project!.expectedEndDate!.day}/${_project!.expectedEndDate!.month}/${_project!.expectedEndDate!.year}',
                              ),
                            ),
                          if (_project!.initialBudget != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Budget',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              title: const Text('Budget initial'),
                              subtitle: Text(
                                '${_project!.initialBudget!.toStringAsFixed(2)} €',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.DRAFT:
        return Colors.grey.shade200;
      case ProjectStatus.IN_PROGRESS:
        return Colors.blue.shade100;
      case ProjectStatus.ON_HOLD:
        return Colors.orange.shade100;
      case ProjectStatus.COMPLETED:
        return Colors.green.shade100;
      case ProjectStatus.CANCELLED:
        return Colors.red.shade100;
    }
  }
}
