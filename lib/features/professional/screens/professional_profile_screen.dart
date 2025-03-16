import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../stories/widgets/story_list.dart';
import '../../auth/services/auth_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../../payments/screens/payment_history_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  final AuthService _authService = AuthService();
  String? _professionalId;

  @override
  void initState() {
    super.initState();
    _loadProfessionalId();
  }

  Future<void> _loadProfessionalId() async {
    final id = await _authService.getCurrentUserId();
    if (mounted) {
      setState(() {
        _professionalId = id;
      });
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.text,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColors.text,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_professionalId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stories
              StoryList(
                professionalId: _professionalId!,
                canCreate: true,
              ),

              // En-tête avec photo de profil et QR code
              Container(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            'SB',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 24.w),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      QrImageView(
                                        data: 'professional_${_professionalId}',
                                        version: QrVersions.auto,
                                        size: 200.w,
                                        backgroundColor: Colors.white,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Scanner pour identifier le professionnel',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8.w),
                            child: QrImageView(
                              data: 'professional_${_professionalId}',
                              version: QrVersions.auto,
                              size: 80.w,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Nom du Professionnel',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'contact@professionnel.com',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Statistiques
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Clients',
                        '127',
                        Icons.people,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Services',
                        '24',
                        Icons.spa,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'RDV',
                        '450',
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Menu
              _buildMenuItem(
                context,
                'Paramètres',
                Icons.settings,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Historique des paiements',
                Icons.payment,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                'Notifications',
                Icons.notifications,
                onTap: () {
                  // TODO: Implémenter les notifications
                },
              ),
              _buildMenuItem(
                context,
                'Aide',
                Icons.help,
                onTap: () {
                  // TODO: Implémenter l'aide
                },
              ),
              _buildMenuItem(
                context,
                'À propos',
                Icons.info,
                onTap: () {
                  // TODO: Implémenter à propos
                },
              ),
              _buildMenuItem(
                context,
                'Déconnexion',
                Icons.logout,
                isDestructive: true,
                onTap: () async {
                  await _authService.signOut();
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
