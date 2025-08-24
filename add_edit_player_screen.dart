import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/player.dart';
import '../../providers/team_provider.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';

class AddEditPlayerScreen extends StatefulWidget {
  final Player? player; // null per nuovo giocatore
  
  const AddEditPlayerScreen({super.key, this.player});

  @override
  State<AddEditPlayerScreen> createState() => _AddEditPlayerScreenState();
}

class _AddEditPlayerScreenState extends State<AddEditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _notesController;
  
  String _selectedPosition = AppConstants.positions.first;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;
  
  bool get _isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final player = widget.player;
    
    _nameController = TextEditingController(text: player?.name ?? '');
    _numberController = TextEditingController(text: player?.number?.toString() ?? '');
    _phoneController = TextEditingController(text: player?.phone ?? '');
    _emailController = TextEditingController(text: player?.email ?? '');
    _heightController = TextEditingController(text: player?.height?.toString() ?? '');
    _weightController = TextEditingController(text: player?.weight?.toString() ?? '');
    _emergencyContactController = TextEditingController(text: player?.emergencyContact ?? '');
    _emergencyPhoneController = TextEditingController(text: player?.emergencyPhone ?? '');
    _notesController = TextEditingController(text: player?.notes ?? '');
    
    _selectedPosition = player?.position ?? AppConstants.positions.first;
    _selectedBirthDate = player?.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Giocatore' : 'Nuovo Giocatore'),
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
              _buildSectionTitle('Dati Personali'),
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Informazioni Calcistiche'),
              const SizedBox(height: 16),
              _buildFootballInfoSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Dati Fisici'),
              const SizedBox(height: 16),
              _buildPhysicalInfoSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Contatti di Emergenza'),
              const SizedBox(height: 16),
              _buildEmergencySection(),
              
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

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        CustomTextField(
          label: 'Nome Completo *',
          controller: _nameController,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Il nome è obbligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isNotEmpty == true && !value!.isValidEmail) {
              return 'Email non valida';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Telefono',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isNotEmpty == true && !value!.isValidPhone) {
              return 'Numero di telefono non valido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              locale: const Locale('it', 'IT'),
            );
            if (date != null) {
              setState(() {
                _selectedBirthDate = date;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Seleziona data di nascita',
                  style: TextStyle(
                    color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFootballInfoSection() {
    return Column(
      children: [
        CustomTextField(
          label: 'Numero Maglia',
          controller: _numberController,
          keyboardType: TextInputType.number,
          hint: 'Lascia vuoto se non assegnato',
          validator: (value) {
            if (value?.isNotEmpty == true) {
              final number = int.tryParse(value!);
              if (number == null || number < 1 || number > 99) {
                return 'Numero non valido (1-99)';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          label: 'Posizione *',
          value: _selectedPosition,
          items: AppConstants.positions
              .map((position) => DropdownMenuItem(
                    value: position,
                    child: Text(position),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPosition = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: 'Altezza (cm)',
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isNotEmpty == true) {
                final height = double.tryParse(value!);
                if (height == null || height < 150 || height > 220) {
                  return 'Altezza non valida';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextField(
            label: 'Peso (kg)',
            controller: _weightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isNotEmpty == true) {
                final weight = double.tryParse(value!);
                if (weight == null || weight < 40 || weight > 150) {
                  return 'Peso non valido';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Column(
      children: [
        CustomTextField(
          label: 'Nome Contatto di Emergenza',
          controller: _emergencyContactController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Telefono di Emergenza',
          controller: _emergencyPhoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return CustomTextField(
      label: 'Note e Osservazioni',
      controller: _notesController,
      maxLines: 4,
      hint: 'Inserisci note, caratteristiche, obiettivi...',
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: _isEditing ? 'Salva Modifiche' : 'Aggiungi Giocatore',
            onPressed: _isLoading ? null : _savePlayer,
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

  Future<void> _savePlayer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final teamProvider = context.read<TeamProvider>();
      
      // Controlla se il numero è già in uso (solo se specificato)
      int? number;
      if (_numberController.text.trim().isNotEmpty) {
        number = int.parse(_numberController.text);
        try {
          final existingPlayer = teamProvider.players
              .firstWhere((p) => p.number == number && p.id != widget.player?.id);
          throw Exception('Numero di maglia $number già in uso da ${existingPlayer.name}');
        } catch (e) {
          // Se non trova nessun giocatore con quel numero, è OK
          if (e is! StateError) rethrow;
        }
      }

      final player = Player(
        id: widget.player?.id ?? AppUtils.generateId(),
        name: _nameController.text.trim(),
        number: number,
        position: _selectedPosition,
        birthDate: _selectedBirthDate,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        height: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
        weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        emergencyContact: _emergencyContactController.text.trim().isNotEmpty ? _emergencyContactController.text.trim() : null,
        emergencyPhone: _emergencyPhoneController.text.trim().isNotEmpty ? _emergencyPhoneController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        isActive: widget.player?.isActive ?? true,
        createdAt: widget.player?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await teamProvider.updatePlayer(player);
        AppUtils.showSuccessSnackBar(context, 'Giocatore aggiornato con successo');
      } else {
        await teamProvider.addPlayer(player);
        AppUtils.showSuccessSnackBar(context, 'Giocatore aggiunto con successo');
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
