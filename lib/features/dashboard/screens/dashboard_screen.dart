import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/appointments_today.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/services_chart.dart';
import '../widgets/clients_list.dart';
import '../widgets/loyalty_summary.dart'; // Import du widget LoyaltySummary

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tableau de bord',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            color: AppColors.text,
            onPressed: () {
              // TODO: Ouvrir le calendrier
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            color: AppColors.text,
            onPressed: () {
              // TODO: Ouvrir les notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: Icon(Icons.analytics_outlined, size: 24.w),
              text: 'Statistiques',
            ),
            Tab(
              icon: Icon(Icons.people_outline, size: 24.w),
              text: 'Clients',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Vue Statistiques
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                // Cartes de statistiques
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Rendez-vous',
                          value: '12',
                          subtitle: "Aujourd'hui",
                          icon: Icons.calendar_month,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: StatCard(
                          title: 'Revenus',
                          value: '€ 450',
                          subtitle: "Aujourd'hui",
                          icon: Icons.euro,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Clients',
                          value: '8',
                          subtitle: 'Nouveaux ce mois',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: StatCard(
                          title: 'Services',
                          value: '24',
                          subtitle: 'Total',
                          icon: Icons.spa,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Programme fidélité
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const LoyaltySummary(),
                ),
                SizedBox(height: 24.h),

                // Rendez-vous d'aujourd'hui
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Rendez-vous d'aujourd'hui",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                const AppointmentsToday(),
                SizedBox(height: 24.h),

                // Graphique des revenus
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Revenus',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                const RevenueChart(),
                SizedBox(height: 24.h),

                // Graphique des services
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Services populaires',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                const ServicesChart(),
              ],
            ),
          ),

          // Vue Clients
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: const ClientsList(),
          ),
        ],
      ),
    );
  }
}
