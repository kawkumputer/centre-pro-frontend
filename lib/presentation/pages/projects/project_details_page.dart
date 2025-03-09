import 'package:flutter/material.dart';
import '../../../domain/models/project.dart';

class ProjectDetailsPage extends StatelessWidget {
  final Project project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Naviguer vers la page d'édition
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Statut',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _ProjectStatusChip(status: project.status),
                    ],
                  ),
                  const Divider(height: 32),
                  if (project.description != null) ...[
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(project.description!),
                    const Divider(height: 32),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date de début',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(_formatDate(project.startDate)),
                          ],
                        ),
                      ),
                      if (project.expectedEndDate != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date de fin prévue',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(_formatDate(project.expectedEndDate!)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (project.initialBudget != null) ...[
                    const Divider(height: 32),
                    Text(
                      'Budget initial',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${project.initialBudget!.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  Text(
                    'Propriétaire',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${project.owner.firstName} ${project.owner.lastName}'),
                  const SizedBox(height: 4),
                  Text(
                    project.owner.email,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
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
