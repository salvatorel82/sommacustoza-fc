import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final Widget? prefixIcon;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
        ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool showClearButton;

  const CustomSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onClear,
    this.controller,
    this.focusNode,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint ?? 'Cerca...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: showClearButton && 
                   controller != null && 
                   controller!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

// 🚀 WIDGET DATEPICKER CORRETTO E MIGLIORATO
class CustomDateTimePicker extends StatefulWidget {
  final String? label;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final String? hint;
  final bool showTime;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDateTimePicker({
    super.key,
    this.label,
    this.selectedDate,
    this.selectedTime,
    this.onDateTimeChanged,
    this.onDateChanged,
    this.onTimeChanged,
    this.hint,
    this.showTime = true,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime? _internalDate;
  TimeOfDay? _internalTime;

  @override
  void initState() {
    super.initState();
    _internalDate = widget.selectedDate;
    _internalTime = widget.selectedTime;
  }

  @override
  void didUpdateWidget(CustomDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _internalDate = widget.selectedDate;
    }
    if (widget.selectedTime != oldWidget.selectedTime) {
      _internalTime = widget.selectedTime;
    }
  }

  void _updateDateTime() {
    if (_internalDate != null && _internalTime != null && widget.showTime) {
      final combinedDateTime = DateTime(
        _internalDate!.year,
        _internalDate!.month,
        _internalDate!.day,
        _internalTime!.hour,
        _internalTime!.minute,
      );
      widget.onDateTimeChanged?.call(combinedDateTime);
    } else if (_internalDate != null && !widget.showTime) {
      widget.onDateTimeChanged?.call(_internalDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Otteniamo la larghezza dello schermo per decidere il layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Layout responsivo: colonna su schermi stretti, riga su schermi larghi
        widget.showTime && isNarrowScreen
            ? Column(
                children: [
                  _DatePickerField(
                    selectedDate: _internalDate,
                    onDateChanged: (date) {
                      setState(() {
                        _internalDate = date;
                      });
                      widget.onDateChanged?.call(date);
                      _updateDateTime();
                    },
                    hint: widget.hint ?? 'Seleziona data',
                    enabled: widget.enabled,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                  ),
                  const SizedBox(height: 12),
                  _TimePickerField(
                    selectedTime: _internalTime,
                    onTimeChanged: (time) {
                      setState(() {
                        _internalTime = time;
                      });
                      widget.onTimeChanged?.call(time);
                      _updateDateTime();
                    },
                    enabled: widget.enabled,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: widget.showTime ? 3 : 4,
                    child: _DatePickerField(
                      selectedDate: _internalDate,
                      onDateChanged: (date) {
                        setState(() {
                          _internalDate = date;
                        });
                        widget.onDateChanged?.call(date);
                        _updateDateTime();
                      },
                      hint: widget.hint ?? 'Seleziona data',
                      enabled: widget.enabled,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                    ),
                  ),
                  if (widget.showTime) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _TimePickerField(
                        selectedTime: _internalTime,
                        onTimeChanged: (time) {
                          setState(() {
                            _internalTime = time;
                          });
                          widget.onTimeChanged?.call(time);
                          _updateDateTime();
                        },
                        enabled: widget.enabled,
                      ),
                    ),
                  ],
                ],
              ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateChanged;
  final String hint;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _DatePickerField({
    this.selectedDate,
    this.onDateChanged,
    required this.hint,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    
    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
          border: Border.all(
            color: hasDate ? Colors.green : Colors.grey.shade200,
            width: hasDate ? 2 : 1,
          ),
          borderRadius: AppTheme.mediumRadius,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: enabled ? (hasDate ? Colors.green : Colors.grey) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                hasDate
                    ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                    : hint,
                style: TextStyle(
                  color: hasDate 
                      ? AppTheme.textPrimary 
                      : AppTheme.textHint,
                  fontSize: 16,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDate)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      locale: const Locale('it', 'IT'),
    );
    
    if (date != null) {
      onDateChanged?.call(date);
    }
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool enabled;

  const _TimePickerField({
    this.selectedTime,
    this.onTimeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasTime = selectedTime != null;
    
    return InkWell(
      onTap: enabled ? () => _selectTime(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
          border: Border.all(
            color: hasTime ? Colors.blue : Colors.grey.shade200,
            width: hasTime ? 2 : 1,
          ),
          borderRadius: AppTheme.mediumRadius,
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: enabled ? (hasTime ? Colors.blue : Colors.grey) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                hasTime
                    ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Ora',
                style: TextStyle(
                  color: hasTime 
                      ? AppTheme.textPrimary 
                      : AppTheme.textHint,
                  fontSize: 16,
                  fontWeight: hasTime ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasTime)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      onTimeChanged?.call(time);
    }
  }
}

class CustomSlider extends StatelessWidget {
  final String? label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? labelBuilder;
  final Color? activeColor;

  const CustomSlider({
    super.key,
    this.label,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChanged,
    this.labelBuilder,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                labelBuilder?.call(value) ?? value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: activeColor ?? AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor ?? AppTheme.primaryColor,
            inactiveTrackColor: (activeColor ?? AppTheme.primaryColor).withOpacity(0.2),
            thumbColor: activeColor ?? AppTheme.primaryColor,
            overlayColor: (activeColor ?? AppTheme.primaryColor).withOpacity(0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final bool enabled;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.leading,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      value: value,
      onChanged: enabled ? onChanged : null,
      secondary: leading,
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
