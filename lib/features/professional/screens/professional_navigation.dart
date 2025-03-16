import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'professional_profile_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../services/screens/services_screen.dart';

class ProfessionalNavigation extends StatefulWidget {
  const ProfessionalNavigation({super.key});

  @override
  State<ProfessionalNavigation> createState() => _ProfessionalNavigationState();
}

class _ProfessionalNavigationState extends State<ProfessionalNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreen(),
    const ServicesScreen(),
    const ProfessionalProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard_outlined,
                size: 24.sp,
              ),
              selectedIcon: Icon(
                Icons.dashboard,
                size: 24.sp,
                color: AppColors.primary,
              ),
              label: 'Tableau de bord',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 24.sp,
              ),
              selectedIcon: Icon(
                Icons.calendar_today,
                size: 24.sp,
                color: AppColors.primary,
              ),
              label: 'Calendrier',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.spa_outlined,
                size: 24.sp,
              ),
              selectedIcon: Icon(
                Icons.spa,
                size: 24.sp,
                color: AppColors.primary,
              ),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                size: 24.sp,
              ),
              selectedIcon: Icon(
                Icons.person,
                size: 24.sp,
                color: AppColors.primary,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
