import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/project.dart';
import '../../../domain/models/project_status.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../infrastructure/providers/project_repository_provider.dart';
import '../../widgets/loading_indicator.dart';

class ProjectFormPage extends StatefulWidget {
  final String? projectId;

  const ProjectFormPage({super.key, this.projectId});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  late final ProjectRepository _projectRepository;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _error;
  Project? _project;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  DateTime? _expectedEndDate;
  late ProjectStatus _status;
  late final TextEditingController _initialBudgetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _startDate = DateTime.now();
    _status = ProjectStatus.DRAFT;
    _initialBudgetController = TextEditingController();

    if (widget.projectId != null) {
      _loadProject();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectRepository = ProjectRepositoryProvider.of(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _initialBudgetController.dispose();
    super.dispose();
  }

  Future<void> _loadProject() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final project = await _projectRepository.getProject(widget.projectId!);
      setState(() {
        _project = project;
        _nameController.text = project.name;
        _descriptionController.text = project.description ?? '';
        _startDate = project.startDate;
        _expectedEndDate = project.expectedEndDate;
        _status = project.status;
        _initialBudgetController.text = project.initialBudget?.toString() ?? '';
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
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final values = _formKey.currentState!.value;
      final name = values['name'] as String;
      final description = values['description'] as String?;
      final initialBudget = values['initialBudget'] != null
          ? double.tryParse(values['initialBudget'].toString())
          : null;

      if (_project == null) {
        await _projectRepository.createProject(
          name: name,
          description: description,
          startDate: _startDate,
          expectedEndDate: _expectedEndDate,
          status: _status,
          initialBudget: initialBudget,
        );
      } else {
        await _projectRepository.updateProject(
          _project!.id,
          name: name,
          description: description,
          startDate: _startDate,
          expectedEndDate: _expectedEndDate,
          status: _status,
          initialBudget: initialBudget,
        );
      }

      if (mounted) {
        context.pop(true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project == null ? 'Nouveau projet' : 'Modifier le projet'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    FormBuilderTextField(
                      name: 'name',
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du projet',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Le nom est obligatoire',
                        ),
                        FormBuilderValidators.minLength(
                          3,
                          errorText: 'Le nom doit contenir au moins 3 caractères',
                        ),
                        FormBuilderValidators.maxLength(
                          100,
                          errorText: 'Le nom ne doit pas dépasser 100 caractères',
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'description',
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Date de début'),
                            subtitle: Text(
                              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            ),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Date de fin prévue'),
                            subtitle: _expectedEndDate == null
                                ? const Text('Non définie')
                                : Text(
                                    '${_expectedEndDate!.day}/${_expectedEndDate!.month}/${_expectedEndDate!.year}',
                                  ),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProjectStatus>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
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
                    FormBuilderTextField(
                      name: 'initialBudget',
                      controller: _initialBudgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget initial',
                        border: OutlineInputBorder(),
                        suffixText: '€',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.numeric(
                          errorText: 'Veuillez entrer un nombre valide',
                        ),
                        FormBuilderValidators.min(
                          0,
                          errorText: 'Le budget ne peut pas être négatif',
                        ),
                      ]),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProject,
                      child: Text(
                        _project == null ? 'Créer le projet' : 'Enregistrer les modifications',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
