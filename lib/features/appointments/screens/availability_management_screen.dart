import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../models/availability.dart';
import '../models/appointment.dart';
import '../services/availability_service.dart';
import '../services/appointment_service.dart';
import '../services/conflict_resolution_service.dart';
import '../widgets/availability_form_dialog.dart';
import '../widgets/availability_timeline.dart';
import '../widgets/calendar_day_marker.dart';
import '../widgets/professional_filter.dart';
import '../widgets/week_view_calendar.dart';
import '../widgets/service_filter.dart';
import '../../professional/controllers/professional_controller.dart';
import '../../services/models/service.dart';

class AvailabilityManagementScreen extends StatefulWidget {
  const AvailabilityManagementScreen({Key? key}) : super(key: key);

  @override
  State<AvailabilityManagementScreen> createState() => _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState extends State<AvailabilityManagementScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;
  List<Availability> _availabilities = [];
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _selectedProfessionalId;
  String? _selectedServiceId;
  Service? _selectedService;
  
  // Vue actuelle (0: mois, 1: semaine, 2: jour)
  int _currentView = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger les disponibilités
      final availabilities = await AvailabilityService.instance.getAvailabilities(
        _selectedProfessionalId ?? 'current_user_id',
      );
      
      // Charger les rendez-vous pour la période sélectionnée
      final startDate = _currentView == 0 
          ? DateTime(_selectedDay.year, _selectedDay.month, 1)
          : _currentView == 1
              ? _getStartOfWeek(_selectedDay)
              : _selectedDay;
              
      final endDate = _currentView == 0
          ? DateTime(_selectedDay.year, _selectedDay.month + 1, 0)
          : _currentView == 1
              ? _getStartOfWeek(_selectedDay).add(const Duration(days: 7))
              : _selectedDay.add(const Duration(days: 1));

      final appointments = await AppointmentService.instance.getAppointmentsByDateRange(
        _selectedProfessionalId ?? 'current_user_id',
        startDate,
        endDate,
      );

      // Si un service est sélectionné, charger ses détails
      if (_selectedServiceId != null) {
        _selectedService = await ServiceController().getServiceById(_selectedServiceId!);
      }

      setState(() {
        _availabilities = availabilities;
        _appointments = appointments.where((appointment) =>
          _selectedServiceId == null || appointment.serviceId == _selectedServiceId
        ).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _showAddAvailabilityDialog([DateTime? initialDate]) async {
    if (_selectedProfessionalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un professionnel')),
      );
      return;
    }

    // Si un service est sélectionné, vérifier les conflits potentiels
    if (_selectedService != null && initialDate != null) {
      final endTime = initialDate.add(Duration(minutes: _selectedService!.duration));
      final conflicts = await ConflictResolutionService.instance
          .findConflictingAppointments(
            _selectedProfessionalId!,
            initialDate,
            endTime,
          );

      if (conflicts.isNotEmpty) {
        // Trouver des créneaux alternatifs
        final suggestions = await ConflictResolutionService.instance
            .findAlternativeTimeSlots(
              professionalId: _selectedProfessionalId!,
              preferredDate: initialDate,
              service: _selectedService!,
            );

        if (suggestions.isNotEmpty) {
          // Afficher les suggestions
          final selectedSlot = await showDialog<TimeSlotSuggestion>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Conflits détectés'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ce créneau n\'est pas disponible. Voici des alternatives :'),
                  const SizedBox(height: 8),
                  ...suggestions.map((suggestion) => ListTile(
                    title: Text(
                      '${suggestion.startTime.hour}:${suggestion.startTime.minute.toString().padLeft(2, '0')} - '
                      '${suggestion.endTime.hour}:${suggestion.endTime.minute.toString().padLeft(2, '0')}'
                    ),
                    subtitle: Text(suggestion.reason),
                    onTap: () => Navigator.of(context).pop(suggestion),
                  )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          );

          if (selectedSlot != null) {
            initialDate = selectedSlot.startTime;
          } else {
            return;
          }
        }
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AvailabilityFormDialog(
        initialDate: initialDate ?? _selectedDay,
        professionalId: _selectedProfessionalId!,
        service: _selectedService,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Widget _buildCalendarDayMarker(DateTime date) {
    final dayAvailabilities = _availabilities.where((a) => 
      a.isAvailableAt(date)).toList();
    
    return CalendarDayMarker(
      availabilities: dayAvailabilities,
      date: date,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des disponibilités'),
        actions: [
          // Boutons de changement de vue
          ToggleButtons(
            isSelected: [
              _currentView == 0,
              _currentView == 1,
              _currentView == 2,
            ],
            onPressed: (index) {
              setState(() {
                _currentView = index;
              });
              _loadData();
            },
            children: const [
              Icon(Icons.calendar_month),
              Icon(Icons.calendar_view_week),
              Icon(Icons.calendar_view_day),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAvailabilityDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ProfessionalFilter(
                  selectedProfessionalId: _selectedProfessionalId,
                  onProfessionalSelected: (professionalId) {
                    setState(() {
                      _selectedProfessionalId = professionalId;
                      // Réinitialiser le service sélectionné
                      _selectedServiceId = null;
                      _selectedService = null;
                    });
                    _loadData();
                  },
                ),
                if (_selectedProfessionalId != null)
                  ServiceFilter(
                    selectedServiceId: _selectedServiceId,
                    onServiceSelected: (serviceId) {
                      setState(() {
                        _selectedServiceId = serviceId;
                        _selectedService = null; // Sera chargé dans _loadData
                      });
                      _loadData();
                    },
                    professionalId: _selectedProfessionalId,
                  ),
                if (_currentView == 0) // Vue mois
                  Card(
                    margin: EdgeInsets.all(8.w),
                    child: TableCalendar(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _loadData();
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          return _buildCalendarDayMarker(date);
                        },
                      ),
                    ),
                  ),
                if (_currentView == 1) // Vue semaine
                  Expanded(
                    child: WeekViewCalendar(
                      selectedDate: _selectedDay,
                      availabilities: _availabilities,
                      appointments: _appointments,
                      onTimeSlotTap: (dateTime) => _showAddAvailabilityDialog(dateTime),
                    ),
                  ),
                if (_currentView == 2) // Vue jour
                  Expanded(
                    child: AvailabilityTimeline(
                      date: _selectedDay,
                      availabilities: _availabilities,
                      appointments: _appointments,
                      onTimeSlotTap: (dateTime) => _showAddAvailabilityDialog(dateTime),
                    ),
                  ),
                if (_currentView == 0)
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(8.w),
                      children: [
                        Text(
                          'Disponibilités du ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (_availabilities.isEmpty && _selectedProfessionalId != null)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                'Aucune disponibilité pour cette journée',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else if (_selectedProfessionalId == null)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                'Veuillez sélectionner un professionnel',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._availabilities
                              .where((a) => a.isAvailableAt(_selectedDay))
                              .map((availability) => Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.access_time),
                                      title: Text(
                                        '${availability.startTime.hour}:${availability.startTime.minute.toString().padLeft(2, '0')} - '
                                        '${availability.endTime.hour}:${availability.endTime.minute.toString().padLeft(2, '0')}',
                                      ),
                                      subtitle: availability.notes != null
                                          ? Text(availability.notes!)
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (availability.isRecurring)
                                            Padding(
                                              padding: EdgeInsets.only(right: 8.w),
                                              child: const Icon(
                                                Icons.repeat,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () async {
                                              final result = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AvailabilityFormDialog(
                                                  initialDate: _selectedDay,
                                                  availability: availability,
                                                  professionalId: _selectedProfessionalId!,
                                                ),
                                              );
                                              if (result == true) {
                                                _loadData();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
