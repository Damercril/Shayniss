import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/theme/app_colors.dart';
import '../../clients/widgets/client_details_modal.dart'; 
import '../widgets/appointment_date_picker.dart'; 
import '../../appointments/screens/appointment_form.dart'; // Importation du formulaire de rendez-vous

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 365));
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTodaySection(),
            _buildWeekCalendar(),
            Expanded(
              child: _buildDaySchedule(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AppointmentDatePicker(
                onDateSelected: (date) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentForm(
                        selectedDateTime: date,
                      ),
                    ),
                  );
                },
                onTimeSelected: (time) {
                  // Cette fonction n'est plus nécessaire car nous utilisons
                  // directement onDateSelected avec la date complète
                },
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, size: 28.w),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Calendrier',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 28.w,
            ),
            onPressed: () {
              // TODO: Ajouter la logique pour basculer vers la vue mensuelle
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'fr_FR').format(now);
    final date = DateFormat('d MMMM', 'fr_FR').format(now);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aujourd\'hui',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${dayName.capitalize()} $date',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return TableCalendar(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      locale: 'fr_FR',
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {
        CalendarFormat.week: 'Semaine',
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors.primary,
          size: 28.w,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors.primary,
          size: 28.w,
        ),
        titleTextStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildDaySchedule() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildAppointmentTile(
          time: '${9 + index * 2}:00',
          name: 'Client ${index + 1}',
          service: index % 2 == 0 ? 'Coiffure' : 'Manucure',
          duration: '1h30',
        );
      },
    );
  }

  Widget _buildAppointmentTile({
    required String time,
    required String name,
    required String service,
    required String duration,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ClientDetailsModal(
            clientName: name,
            appointmentTime: '$time - $duration',
            service: service,
            hasConfirmed: false,
            hasDeposit: false,
            hasPaid: false,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F1EA), // Couleur de base beige
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF9F6F0), // Beige plus clair
              const Color(0xFFF0EBE1), // Beige plus foncé
            ],
          ),
          boxShadow: [
            // Ombre externe principale
            BoxShadow(
              color: const Color(0xFF8B8579).withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            // Ombre douce pour la profondeur
            BoxShadow(
              color: const Color(0xFF8B8579).withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            // Reflet supérieur
            BoxShadow(
              color: const Color(0xFFFFFBF5).withOpacity(0.9),
              offset: const Offset(0, -2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE5E0D8),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Effet de brillance
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFFFBF5).withOpacity(0.3),
                      const Color(0xFFFFFBF5).withOpacity(0),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                // Barre verticale avec effet de profondeur
                Container(
                  width: 4.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(1),
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Informations de temps
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // Informations du client
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        service,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
