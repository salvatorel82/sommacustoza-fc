import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/training.dart';
import '../../providers/calendar_provider.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';

class AddEditTrainingScreen extends StatefulWidget {
  final Training? training; // null per nuovo allenamento
  
  const AddEditTrainingScreen({super.key, this.training});

  @override
  State<AddEditTrainingScreen> createState() => _AddEditTrainingScreenState();
}

class _AddEditTrainingScreenState extends State<AddEditTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  
  String _selectedType = AppConstants.trainingTypes.first;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 90;
  int? _intensity = 5;
  String? _focusArea;
  List<String> _exercises = [];
  bool _isLoading = false;
  
  bool get _isEditing => widget.training != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final training = widget.training;
    
    _locationController = TextEditingController(text: training?.location ?? 'Campo Comunale');
    _descriptionController = TextEditingController(text: training?.description ?? '');
    _notesController = TextEditingController(text: training?.notes ?? '');
    
    _selectedType = training?.type ?? AppConstants.trainingTypes.first;
    _selectedDate = training?.dateTime != null 
        ? DateTime(training!.dateTime.year, training.dateTime.month, training.dateTime.day)
        : null;
    _selectedTime = training?.dateTime != null 
        ? TimeOfDay.fromDateTime(training!.dateTime)
        : null;
    _durationMinutes = training?.durationMinutes ?? 90;
    _intensity = training?.intensity;
    _focusArea = training?.focusArea;
    _exercises = training?.exercises ?? [];
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Allenamento' : 'Nuovo Allenamento'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informazioni Base'),
              const SizedBox(height: 16),
              _buildBasicInfoSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Data e Orario'),
              const SizedBox(height: 16),
              _buildDateTimeSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Dettagli Allenamento'),
              const SizedBox(height: 16),
              _buildTrainingDetailsSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Esercizi'),
              const SizedBox(height: 16),
              _buildExercisesSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Note'),
              const SizedBox(height: 16),
              _buildNotesSection(),
              
              const SizedBox(height: 48),
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        CustomDropdown<String>(
          label: 'Tipo Allenamento *',
          value: _selectedType,
          items: AppConstants.trainingTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              _updateDefaultExercises();
            });
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Luogo *',
          controller: _locationController,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Il luogo è obbligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Descrizione',
          controller: _descriptionController,
          maxLines: 2,
          hint: 'Breve descrizione degli obiettivi...',
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      children: [
        CustomDateTimePicker(
          label: 'Data e Orario *',
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateTimeChanged: (dateTime) {
            setState(() {
              _selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
              _selectedTime = TimeOfDay.fromDateTime(dateTime);
            });
            print('Data e orario selezionati: $dateTime'); // Debug
          },
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
            print('Data selezionata: $date'); // Debug
          },
          onTimeChanged: (time) {
            setState(() {
              _selectedTime = time;
            });
            print('Orario selezionato: $time'); // Debug
          },
          showTime: true,
          enabled: true,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ),
        // Validation Message
        if (_selectedDate == null || _selectedTime == null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data e orario sono obbligatori per salvare l\'allenamento',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTrainingDetailsSection() {
    return Column(
      children: [
        CustomSlider(
          label: 'Durata (minuti)',
          value: _durationMinutes.toDouble(),
          min: 30,
          max: 180,
          divisions: 15,
          onChanged: (value) {
            setState(() {
              _durationMinutes = value.round();
            });
          },
          labelBuilder: (value) => '${value.round()} min',
        ),
        const SizedBox(height: 24),
        CustomSlider(
          label: 'Intensità',
          value: (_intensity ?? 5).toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (value) {
            setState(() {
              _intensity = value.round();
            });
          },
          labelBuilder: (value) => '${value.round()}/10',
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Focus Area',
          initialValue: _focusArea,
          hint: 'Es: Fase offensiva, Calci piazzati, Resistenza...',
          onChanged: (value) {
            _focusArea = value.isNotEmpty ? value : null;
          },
        ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lista Esercizi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomTextButton(
              text: 'Aggiungi',
              onPressed: _addExercise,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_exercises.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nessun esercizio aggiunto',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tocca "Aggiungi" per inserire esercizi',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ...(_exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExercise(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
      ],
    );
  }

  Widget _buildNotesSection() {
    return CustomTextField(
      label: 'Note e Osservazioni',
      controller: _notesController,
      maxLines: 4,
      hint: 'Note per il mister, osservazioni, obiettivi specifici...',
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: _isEditing ? 'Salva Modifiche' : 'Crea Allenamento',
            onPressed: _isLoading ? null : _saveTraining,
            isLoading: _isLoading,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomOutlinedButton(
            text: 'Annulla',
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  void _updateDefaultExercises() {
    // Se non ci sono esercizi, aggiungiamo quelli di default per il tipo
    if (_exercises.isEmpty) {
      switch (_selectedType) {
        case 'Tecnico':
          _exercises = [
            'Riscaldamento 15 min',
            'Passaggi corti 20 min',
            'Controllo e passaggio 25 min',
            'Partitella tecnica 25 min',
            'Defaticamento 5 min',
          ];
          break;
        case 'Fisico':
          _exercises = [
            'Riscaldamento dinamico 15 min',
            'Sprint e cambi direzione 20 min',
            'Lavoro aerobico 25 min',
            'Forza funzionale 10 min',
            'Stretching 5 min',
          ];
          break;
        case 'Tattico':
          _exercises = [
            'Riscaldamento 10 min',
            'Schemi su calcio d\'angolo 20 min',
            'Prove modulo 11vs11 45 min',
            'Situazioni di gioco 20 min',
            'Defaticamento 5 min',
          ];
          break;
        case 'Partitella':
          _exercises = [
            'Riscaldamento 15 min',
            'Torello 15 min',
            'Partitella 11vs11 45 min',
            'Calci di rigore 10 min',
            'Defaticamento 5 min',
          ];
          break;
      }
    }
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onAdd: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveTraining() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      List<String> missingFields = [];
      if (_selectedDate == null) missingFields.add('data');
      if (_selectedTime == null) missingFields.add('orario');
      
      AppUtils.showErrorSnackBar(
        context, 
        'Per favore seleziona: ${missingFields.join(' e ')}'
      );
      
      // Scroll to date section
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }
    
    print('Salvando allenamento - Data: $_selectedDate, Orario: $_selectedTime'); // Debug
    print('DateTime creato: ${DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute)}'); // Debug

    setState(() {
      _isLoading = true;
    });

    try {
      final calendarProvider = context.read<CalendarProvider>();
      
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final training = Training(
        id: widget.training?.id ?? AppUtils.generateId(),
        type: _selectedType,
        dateTime: dateTime,
        location: _locationController.text.trim(),
        durationMinutes: _durationMinutes,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        intensity: _intensity,
        focusArea: _focusArea,
        exercises: _exercises.isNotEmpty ? _exercises : null,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        isCompleted: widget.training?.isCompleted ?? false,
        createdAt: widget.training?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await calendarProvider.updateTraining(training);
        AppUtils.showSuccessSnackBar(context, 'Allenamento aggiornato con successo');
      } else {
        await calendarProvider.addTraining(training);
        AppUtils.showSuccessSnackBar(context, 'Allenamento creato con successo');
      }

      Navigator.of(context).pop();
    } catch (e) {
      AppUtils.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _AddExerciseDialog({required this.onAdd});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Esercizio'),
      content: CustomTextField(
        label: 'Descrizione Esercizio',
        controller: _controller,
        hint: 'Es: Riscaldamento 15 min',
      ),
      actions: [
        CustomTextButton(
          text: 'Annulla',
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomButton(
          text: 'Aggiungi',
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onAdd(_controller.text.trim());
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
