import 'package:flutter/material.dart';
import '../../../domain/models/project.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../widgets/loading_indicator.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMoreData = true;

  late final ProjectRepository _projectRepository;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projects = await _projectRepository.getProjects(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        _projects.addAll(projects);
        _hasMoreData = projects.length == _pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadProjects();
    }
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _projects.clear();
      _currentPage = 0;
      _hasMoreData = true;
    });
    await _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Naviguer vers la page de création de projet
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshProjects,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            : _projects.isEmpty && !_isLoading
                ? const Center(
                    child: Text('Aucun projet trouvé'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _projects.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _projects.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: LoadingIndicator()),
                        );
                      }

                      final project = _projects[index];
                      return _ProjectCard(
                        project: project,
                        onTap: () {
                          // TODO: Naviguer vers la page de détails du projet
                        },
                        onEdit: () {
                          // TODO: Naviguer vers la page d'édition du projet
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer le projet'),
                              content: const Text(
                                'Êtes-vous sûr de vouloir supprimer ce projet ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              await _projectRepository.deleteProject(
                                project.id,
                              );
                              setState(() {
                                _projects.removeAt(index);
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Projet supprimé'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Erreur lors de la suppression: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ProjectStatusChip(status: project.status),
                  Text(
                    'Début: ${_formatDate(project.startDate)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ProjectStatusChip extends StatelessWidget {
  final ProjectStatus status;

  const _ProjectStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case ProjectStatus.DRAFT:
        backgroundColor = Colors.grey;
        break;
      case ProjectStatus.IN_PROGRESS:
        backgroundColor = Colors.blue;
        break;
      case ProjectStatus.ON_HOLD:
        backgroundColor = Colors.orange;
        break;
      case ProjectStatus.COMPLETED:
        backgroundColor = Colors.green;
        break;
      case ProjectStatus.CANCELLED:
        backgroundColor = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
