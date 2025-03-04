import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/availability.dart';
import '../services/availability_service.dart';
import '../services/validation_service.dart';
import '../../services/models/service.dart';

class AvailabilityFormDialog extends StatefulWidget {
  final DateTime initialDate;
  final Availability? availability;
  final String professionalId;
  final Service? service;

  const AvailabilityFormDialog({
    Key? key,
    required this.initialDate,
    this.availability,
    required this.professionalId,
    this.service,
  }) : super(key: key);

  @override
  State<AvailabilityFormDialog> createState() => _AvailabilityFormDialogState();
}

class _AvailabilityFormDialogState extends State<AvailabilityFormDialog> {
  late DateTime _startTime;
  late DateTime _endTime;
  bool _isRecurring = false;
  String? _recurrenceRule;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startTime = widget.availability?.startTime ?? TimeOfDay.fromDateTime(widget.initialDate);
    _endTime = widget.availability?.endTime ?? 
        (widget.service != null
            ? TimeOfDay.fromDateTime(
                widget.initialDate.add(Duration(minutes: widget.service!.duration)))
            : TimeOfDay.fromDateTime(widget.initialDate.add(const Duration(hours: 1))));
    _isRecurring = widget.availability?.isRecurring ?? false;
    _recurrenceRule = widget.availability?.recurrenceRule;
    _notesController.text = widget.availability?.notes ?? '';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
    );

    if (picked != null) {
      setState(() {
        final DateTime base = isStartTime ? _startTime : _endTime;
        final DateTime newTime = DateTime(
          base.year,
          base.month,
          base.day,
          picked.hour,
          picked.minute,
        );
        if (isStartTime) {
          _startTime = newTime;
          // Si l'heure de fin est avant l'heure de début, on l'ajuste
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = newTime;
          // Si l'heure de fin est avant l'heure de début, on l'ajuste
          if (_endTime.isBefore(_startTime)) {
            _startTime = _endTime.subtract(const Duration(hours: 1));
          }
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => _isSaving = true);

      // Valider la règle de récurrence si activée
      if (_isRecurring && _recurrenceRule != null) {
        final recurrenceValidation = ValidationService.instance
            .validateRecurrenceRule(_recurrenceRule!);
        
        if (!recurrenceValidation.isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(recurrenceValidation.errorMessage!)),
          );
          return;
        }
      }

      // Valider les horaires et les conflits
      final validation = await ValidationService.instance.validateNewAvailability(
        widget.professionalId,
        widget.initialDate,
        _startTime,
        _endTime,
        excludeAvailabilityId: widget.availability?.id,
      );

      if (!validation.isValid) {
        String message = validation.errorMessage!;
        if (validation.conflicts != null && validation.conflicts!.isNotEmpty) {
          message += '\n' + validation.conflicts!.join('\n');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      if (widget.availability == null) {
        // Création d'une nouvelle disponibilité
        await AvailabilityService.instance.createRecurringAvailability(
          professionalId: widget.professionalId,
          startTime: _startTime,
          endTime: _endTime,
          recurrenceRule: _isRecurring ? _recurrenceRule ?? '' : '',
          notes: _notesController.text.trim(),
        );
      } else {
        // Mise à jour d'une disponibilité existante
        final updatedAvailability = Availability(
          id: widget.availability!.id,
          professionalId: widget.professionalId,
          startTime: _startTime,
          endTime: _endTime,
          isRecurring: _isRecurring,
          recurrenceRule: _isRecurring ? _recurrenceRule : null,
          notes: _notesController.text.trim(),
        );

        await AvailabilityService.instance.updateAvailability(updatedAvailability);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.w),
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.availability == null ? 'Nouvelle disponibilité' : 'Modifier la disponibilité',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (widget.service != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Card(
                    color: Color(int.parse(widget.service!.color)).withOpacity(0.1),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(int.parse(widget.service!.color)),
                        child: Icon(
                          IconData(widget.service!.iconData, fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(widget.service!.name),
                      subtitle: Text(
                        'Durée: ${widget.service!.duration} min - Prix: ${widget.service!.price.toStringAsFixed(2)}€',
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Heure de début'),
                      subtitle: Text(TimeOfDay.fromDateTime(_startTime).format(context)),
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Heure de fin'),
                      subtitle: Text(TimeOfDay.fromDateTime(_endTime).format(context)),
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Récurrent'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
              if (_isRecurring) ...[
                DropdownButtonFormField<String>(
                  value: _recurrenceRule,
                  decoration: const InputDecoration(
                    labelText: 'Fréquence',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'FREQ=DAILY',
                      child: Text('Tous les jours'),
                    ),
                    DropdownMenuItem(
                      value: 'FREQ=WEEKLY',
                      child: Text('Toutes les semaines'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _recurrenceRule = value),
                ),
                SizedBox(height: 8.h),
              ],
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Ajouter des notes (optionnel)',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer des notes';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
