import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/project.dart';
import '../../../domain/repositories/project_repository.dart';

class ProjectFormPage extends StatefulWidget {
  final Project? project;

  const ProjectFormPage({super.key, this.project});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late final ProjectRepository _projectRepository;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _initialBudgetController;
  late DateTime _startDate;
  DateTime? _expectedEndDate;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _descriptionController = TextEditingController(text: widget.project?.description);
    _initialBudgetController = TextEditingController(
      text: widget.project?.initialBudget?.toString(),
    );
    _startDate = widget.project?.startDate ?? DateTime.now();
    _expectedEndDate = widget.project?.expectedEndDate;
    _status = widget.project?.status ?? ProjectStatus.DRAFT;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _initialBudgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_expectedEndDate ?? _startDate),
      firstDate: isStartDate ? DateTime(2000) : _startDate,
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Si la date de fin est avant la nouvelle date de début, on la réinitialise
          if (_expectedEndDate != null && _expectedEndDate!.isBefore(_startDate)) {
            _expectedEndDate = null;
          }
        } else {
          _expectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double? initialBudget = _initialBudgetController.text.isNotEmpty
          ? double.parse(_initialBudgetController.text)
          : null;

      if (widget.project == null) {
        // Création d'un nouveau projet
        await _projectRepository.createProject(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          startDate: _startDate,
          expectedEndDate: _expectedEndDate,
          status: _status,
          initialBudget: initialBudget,
        );
      } else {
        // Mise à jour d'un projet existant
        await _projectRepository.updateProject(
          widget.project!.id,
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          startDate: _startDate,
          expectedEndDate: _expectedEndDate,
          status: _status,
          initialBudget: initialBudget,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'Nouveau Projet' : 'Modifier le Projet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du projet *',
                hintText: 'Entrez le nom du projet',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est obligatoire';
                }
                if (value.length < 3) {
                  return 'Le nom doit contenir au moins 3 caractères';
                }
                if (value.length > 100) {
                  return 'Le nom ne doit pas dépasser 100 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Entrez une description du projet',
              ),
              maxLines: 3,
              maxLength: 2000,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Date de début: ${_formatDate(_startDate)}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Date de fin: ${_expectedEndDate != null ? _formatDate(_expectedEndDate!) : 'Non définie'}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProjectStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Statut *',
              ),
              items: ProjectStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialBudgetController,
              decoration: const InputDecoration(
                labelText: 'Budget initial',
                hintText: 'Entrez le budget initial',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  try {
                    double.parse(value);
                  } catch (_) {
                    return 'Veuillez entrer un montant valide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProject,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.project == null ? 'Créer le projet' : 'Enregistrer',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
