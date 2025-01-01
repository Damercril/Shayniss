import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/client_selection_dialog.dart';
import '../widgets/service_selection_dialog.dart';
import '../widgets/time_slot_selection_dialog.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Map<String, dynamic>? appointment;

  const AppointmentFormScreen({
    super.key,
    this.appointment,
  });

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientController;
  late TextEditingController _serviceController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;
  dynamic _selectedClientId;
  dynamic _selectedServiceId;
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _clientController = TextEditingController(
      text: widget.appointment?['clientName'] ?? '',
    );
    _serviceController = TextEditingController(
      text: widget.appointment?['service'] ?? '',
    );
    _dateController = TextEditingController(
      text: widget.appointment?['date'] ?? '',
    );
    _timeController = TextEditingController(
      text: widget.appointment?['time'] ?? '',
    );
    _durationController = TextEditingController(
      text: widget.appointment?['duration'] ?? '',
    );
    _notesController = TextEditingController(
      text: widget.appointment?['notes'] ?? '',
    );
  }

  @override
  void dispose() {
    _clientController.dispose();
    _serviceController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.appointment == null
              ? 'Nouveau rendez-vous'
              : 'Modifier le rendez-vous',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveAppointment,
            child: Text(
              'Enregistrer',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client
              _buildTextField(
                controller: _clientController,
                label: 'Client',
                hint: 'Sélectionner un client',
                prefixIcon: Icons.person_outline,
                readOnly: true,
                onTap: () async {
                  final client = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ClientSelectionDialog(),
                  );
                  if (client != null) {
                    setState(() {
                      _clientController.text = client['name'];
                      _selectedClientId = client['id'];
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),

              // Service
              _buildTextField(
                controller: _serviceController,
                label: 'Service',
                hint: 'Sélectionner un service',
                prefixIcon: Icons.spa_outlined,
                readOnly: true,
                onTap: () async {
                  final service = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ServiceSelectionDialog(),
                  );
                  if (service != null) {
                    setState(() {
                      _serviceController.text = service['name'];
                      _selectedServiceId = service['id'];
                      _durationController.text = service['duration'];
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),

              // Date et heure
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dateController,
                      label: 'Date',
                      hint: 'JJ/MM/AAAA',
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          _dateController.text =
                              '${date.day}/${date.month}/${date.year}';
                          _selectedDate = date;

                          // Si un service est sélectionné, on peut choisir l'heure
                          if (_selectedServiceId != null) {
                            final timeSlot = await showDialog<DateTime>(
                              context: context,
                              builder: (context) => TimeSlotSelectionDialog(
                                selectedDate: date,
                                serviceDuration: const Duration(minutes: 60), // TODO: Utiliser la vraie durée du service
                              ),
                            );
                            if (timeSlot != null) {
                              setState(() {
                                _timeController.text = '${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}';
                                _selectedTimeSlot = timeSlot;
                              });
                            }
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _timeController,
                      label: 'Heure',
                      hint: 'HH:MM',
                      prefixIcon: Icons.access_time_outlined,
                      readOnly: true,
                      onTap: () async {
                        if (_selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez d\'abord sélectionner une date'),
                            ),
                          );
                          return;
                        }

                        final timeSlot = await showDialog<DateTime>(
                          context: context,
                          builder: (context) => TimeSlotSelectionDialog(
                            selectedDate: _selectedDate!,
                            serviceDuration: const Duration(minutes: 60), // TODO: Utiliser la vraie durée du service
                          ),
                        );
                        if (timeSlot != null) {
                          setState(() {
                            _timeController.text = '${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}';
                            _selectedTimeSlot = timeSlot;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Durée
              _buildTextField(
                controller: _durationController,
                label: 'Durée',
                hint: 'Durée du rendez-vous',
                prefixIcon: Icons.timer_outlined,
              ),
              SizedBox(height: 16.h),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Ajouter des notes...',
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      // TODO: Sauvegarder le rendez-vous
      Navigator.pop(context);
    }
  }
}
