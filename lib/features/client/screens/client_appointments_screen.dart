import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shayniss/core/theme/app_colors.dart';
import 'package:shayniss/features/client/screens/professional_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClientAppointmentsScreen extends StatefulWidget {
  const ClientAppointmentsScreen({super.key});

  @override
  State<ClientAppointmentsScreen> createState() => _ClientAppointmentsScreenState();
}

class _ClientAppointmentsScreenState extends State<ClientAppointmentsScreen> with SingleTickerProviderStateMixin {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes Rendez-vous',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(upcoming: true),
          _buildAppointmentsList(upcoming: false),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList({required bool upcoming}) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: upcoming
          ? [
              _buildAppointmentCard(
                date: '02 Janvier 2025',
                time: '10:00',
                duration: '1h30',
                service: 'Coupe + Brushing',
                price: '45€',
                professional: 'Sarah Martin',
                address: '15 rue des Lilas, 75011 Paris',
                status: 'À venir',
                upcoming: true,
                profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                paymentMethod: 'Carte bancaire',
                professionalId: 'sarah-martin',
              ),
              SizedBox(height: 16.h),
              _buildAppointmentCard(
                date: '05 Janvier 2025',
                time: '14:30',
                duration: '2h',
                service: 'Coloration',
                price: '75€',
                professional: 'Marie Dubois',
                address: '8 avenue Victor Hugo, 75016 Paris',
                status: 'À venir',
                upcoming: true,
                profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
                paymentMethod: 'PayPal',
                professionalId: 'marie-dubois',
              ),
            ]
          : [
              _buildAppointmentCard(
                date: '5 Jan 2024',
                time: '11:00',
                duration: '1h',
                service: 'Manucure',
                price: '35€',
                professional: 'Julie Bernard',
                address: '23 rue du Commerce, 75015 Paris',
                status: 'Terminé',
                rating: 4,
                upcoming: false,
                profileImage: 'https://example.com/julie-bernard.jpg',
                paymentMethod: 'Espèces',
                professionalId: 'julie-bernard',
              ),
              SizedBox(height: 16.h),
              _buildAppointmentCard(
                date: '2 Jan 2024',
                time: '16:30',
                duration: '2h',
                service: 'Massage + Soin',
                price: '120€',
                professional: 'Emma Laurent',
                address: '45 rue de la Paix, 75002 Paris',
                status: 'Terminé',
                rating: 5,
                upcoming: false,
                profileImage: 'https://example.com/emma-laurent.jpg',
                paymentMethod: 'Carte bancaire',
                professionalId: 'emma-laurent',
              ),
            ],
    );
  }

  Widget _buildAppointmentCard({
    required String date,
    required String time,
    required String duration,
    required String service,
    required String price,
    required String professional,
    required String address,
    required String status,
    required bool upcoming,
    String? profileImage,
    String paymentMethod = 'Carte bancaire',  // Par défaut
    int? rating,
    required String professionalId,
  }) {
    // Convertir la date et l'heure en DateTime
    final DateTime appointmentDateTime = DateTime.parse('${date.split(' ')[2]}-${_getMonthNumber(date.split(' ')[1])}-${date.split(' ')[0].padLeft(2, '0')} ${time}:00');
    final bool needsConfirmation = upcoming && 
        appointmentDateTime.difference(DateTime.now()).inHours <= 12 && 
        appointmentDateTime.isAfter(DateTime.now()) &&
        status == 'À venir';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$time • $duration',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfessionalProfileScreen(
                    professionalId: professionalId,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Hero(
                  tag: 'professional_avatar_$professionalId',
                  child: CircleAvatar(
                    radius: 24.r,
                    backgroundImage: profileImage != null && profileImage.isNotEmpty
                        ? CachedNetworkImageProvider(profileImage) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.jpg'),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        service,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          size: 14.w,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          paymentMethod,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24.w,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.w,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          if (!upcoming && rating != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < (rating ?? 0) ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                    size: 16.w,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Votre note',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          if (upcoming) ...[
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmer le rendez-vous'),
                        content: Text('Voulez-vous confirmer votre rendez-vous du $date à $time avec $professional ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rendez-vous confirmé !'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Confirmer'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24.w,
                  ),
                  tooltip: 'Confirmer',
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Annuler le rendez-vous'),
                        content: Text('Êtes-vous sûr de vouloir annuler votre rendez-vous du $date à $time avec $professional ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Non'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rendez-vous annulé'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Oui, annuler'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 24.w,
                  ),
                  tooltip: 'Annuler',
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Replanifier le rendez-vous'),
                        content: Text('Voulez-vous replanifier votre rendez-vous du $date à $time avec $professional ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Non'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Oui, replanifier'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.edit_calendar_outlined,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                  tooltip: 'Replanifier',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'À venir':
        return AppColors.primary;
      case 'Terminé':
        return Colors.green;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMonthNumber(String monthName) {
    const months = {
      'Jan': '01', 'Fév': '02', 'Mar': '03', 'Avr': '04',
      'Mai': '05', 'Juin': '06', 'Juil': '07', 'Aoû': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Déc': '12'
    };
    return months[monthName] ?? '01';
  }
}
