import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/staff.dart';
import '../../providers/team_provider.dart';
import '../../widgets/common/custom_buttons.dart';
import '../../widgets/common/custom_inputs.dart';

class AddEditStaffScreen extends StatefulWidget {
  final Staff? staff; // null per nuovo membro staff
  
  const AddEditStaffScreen({super.key, this.staff});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _qualificationsController;
  late TextEditingController _experienceController;
  late TextEditingController _notesController;
  
  String _selectedRole = AppConstants.staffRoles.first;
  DateTime? _selectedBirthDate;
  DateTime? _selectedJoinedDate;
  List<String> _selectedPermissions = [];
  bool _isLoading = false;
  
  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final staff = widget.staff;
    
    _nameController = TextEditingController(text: staff?.name ?? '');
    _phoneController = TextEditingController(text: staff?.phone ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _qualificationsController = TextEditingController(text: staff?.qualifications ?? '');
    _experienceController = TextEditingController(text: staff?.experienceYears?.toString() ?? '');
    _notesController = TextEditingController(text: staff?.notes ?? '');
    
    _selectedRole = staff?.role ?? AppConstants.staffRoles.first;
    _selectedBirthDate = staff?.birthDate;
    _selectedJoinedDate = staff?.joinedDate ?? DateTime.now();
    _selectedPermissions = staff?.permissions ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _qualificationsController.dispose();
    _experienceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Staff' : 'Nuovo Staff'),
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
              _buildSectionTitle('Ruolo e Qualifiche'),
              const SizedBox(height: 16),
              _buildRoleInfoSection(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Permessi'),
              const SizedBox(height: 16),
              _buildPermissionsSection(),
              
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
          label: 'Email *',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'L\'email è obbligatoria';
            }
            if (!value!.isValidEmail) {
              return 'Email non valida';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Telefono *',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Il telefono è obbligatorio';
            }
            if (!value!.isValidPhone) {
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
              initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
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
                      ? 'Data di nascita: ${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}'
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

  Widget _buildRoleInfoSection() {
    return Column(
      children: [
        CustomDropdown<String>(
          label: 'Ruolo *',
          value: _selectedRole,
          items: AppConstants.staffRoles
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
              _updateDefaultPermissions();
            });
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Qualifiche e Certificazioni',
          controller: _qualificationsController,
          maxLines: 2,
          hint: 'Es: Patentino UEFA B, Laurea in Scienze Motorie...',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Anni di Esperienza',
          controller: _experienceController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isNotEmpty == true) {
              final years = int.tryParse(value!);
              if (years == null || years < 0 || years > 50) {
                return 'Anni di esperienza non validi';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedJoinedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('it', 'IT'),
            );
            if (date != null) {
              setState(() {
                _selectedJoinedDate = date;
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
                const Icon(Icons.work_outline),
                const SizedBox(width: 12),
                Text(
                  _selectedJoinedDate != null
                      ? 'Data assunzione: ${_selectedJoinedDate!.day.toString().padLeft(2, '0')}/${_selectedJoinedDate!.month.toString().padLeft(2, '0')}/${_selectedJoinedDate!.year}'
                      : 'Seleziona data assunzione',
                  style: TextStyle(
                    color: _selectedJoinedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona i permessi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...StaffPermissions.allPermissions.map((permission) {
          final isSelected = _selectedPermissions.contains(permission);
          final description = StaffPermissions.permissionDescriptions[permission] ?? permission;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPermissions.remove(permission);
                  } else {
                    _selectedPermissions.add(permission);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.black,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNotesSection() {
    return CustomTextField(
      label: 'Note e Osservazioni',
      controller: _notesController,
      maxLines: 4,
      hint: 'Note sui compiti specifici, obiettivi, valutazioni...',
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: _isEditing ? 'Salva Modifiche' : 'Aggiungi Staff',
            onPressed: _isLoading ? null : _saveStaff,
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

  void _updateDefaultPermissions() {
    // Set default permissions based on role
    switch (_selectedRole) {
      case 'Allenatore':
        _selectedPermissions = [
          StaffPermissions.manageTeam,
          StaffPermissions.manageTrainings,
          StaffPermissions.manageMatches,
          StaffPermissions.viewStats,
          StaffPermissions.manageAttendance,
        ];
        break;
      case 'Assistente Allenatore':
        _selectedPermissions = [
          StaffPermissions.manageTrainings,
          StaffPermissions.viewStats,
          StaffPermissions.manageAttendance,
        ];
        break;
      case 'Preparatore Fisico':
        _selectedPermissions = [
          StaffPermissions.manageTrainings,
          StaffPermissions.viewStats,
        ];
        break;
      case 'Fisioterapista':
        _selectedPermissions = [
          StaffPermissions.viewStats,
        ];
        break;
      case 'Team Manager':
        _selectedPermissions = [
          StaffPermissions.manageTeam,
          StaffPermissions.sendNotifications,
          StaffPermissions.exportData,
          StaffPermissions.viewFinancials,
        ];
        break;
      case 'Dirigente':
        _selectedPermissions = StaffPermissions.allPermissions;
        break;
      default:
        _selectedPermissions = [];
    }
    setState(() {});
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final teamProvider = context.read<TeamProvider>();

      final staff = Staff(
        id: widget.staff?.id ?? AppUtils.generateId(),
        name: _nameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        birthDate: _selectedBirthDate,
        qualifications: _qualificationsController.text.trim().isNotEmpty 
            ? _qualificationsController.text.trim() 
            : null,
        experienceYears: _experienceController.text.isNotEmpty 
            ? int.tryParse(_experienceController.text) 
            : null,
        joinedDate: _selectedJoinedDate,
        permissions: _selectedPermissions.isNotEmpty ? _selectedPermissions : null,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        isActive: widget.staff?.isActive ?? true,
        createdAt: widget.staff?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await teamProvider.updateStaff(staff);
        AppUtils.showSuccessSnackBar(context, 'Staff aggiornato con successo');
      } else {
        await teamProvider.addStaff(staff);
        AppUtils.showSuccessSnackBar(context, 'Staff aggiunto con successo');
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
