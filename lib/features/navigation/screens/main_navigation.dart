import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../appointments/widgets/add_appointment_modal.dart';
import '../../services/widgets/add_service_modal.dart';
import '../../services/models/service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const DashboardScreen(),
    const ServicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 65.h,
        width: 65.w,
        margin: EdgeInsets.only(top: 30.h),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 2; // Index du tableau de bord
            });
          },
          backgroundColor: AppColors.primary,
          child: Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 30.w,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Boutons de gauche
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.home_outlined, Icons.home, 'Accueil'),
                      _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, 'Calendrier'),
                    ],
                  ),
                ),
                // Espace pour le bouton flottant
                SizedBox(width: 80.w),
                // Boutons de droite
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(3, Icons.spa_outlined, Icons.spa, 'Services'),
                      _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 24.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        switch (_selectedIndex) {
          case 0: // Home
          case 1: // Calendar
            return AddAppointmentModal(
              service: Service(
                id: '1',
                name: 'Coupe + Brushing',
                category: 'Coiffure',
                description: 'Une coupe et un brushing',
                duration: 45,
                price: 50.0,
              ),
            );
          case 3: // Services
            return const AddServiceModal();
          default:
            return const SizedBox();
        }
      },
    );
  }
}
