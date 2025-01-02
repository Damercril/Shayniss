import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BusinessSettings settings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    settings = BusinessSettings.sample;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Général'),
            Tab(text: 'Horaires'),
            Tab(text: 'Réservation'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildBusinessHoursTab(),
          _buildBookingTab(),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Informations du salon',
            [
              _buildTextField(
                'Nom du salon',
                settings.businessName,
                Icons.business,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                'Adresse',
                settings.address,
                Icons.location_on,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                'Téléphone',
                settings.phone,
                Icons.phone,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                'Email',
                settings.email,
                Icons.email,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSection(
            'Réseaux sociaux',
            [
              _buildTextField(
                'Site web',
                settings.website ?? '',
                Icons.language,
                optional: true,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                'Instagram',
                settings.instagram ?? '',
                Icons.camera_alt,
                optional: true,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                'Facebook',
                settings.facebook ?? '',
                Icons.facebook,
                optional: true,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSection(
            'Préférences',
            [
              _buildDropdownField(
                'Devise',
                settings.currency,
                ['EUR', 'USD', 'GBP'],
                Icons.attach_money,
              ),
              SizedBox(height: 16.h),
              _buildDropdownField(
                'Langue',
                settings.language,
                ['fr', 'en', 'es'],
                Icons.language,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessHoursTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: settings.businessHours.length,
      itemBuilder: (context, index) {
        final hours = settings.businessHours[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hours.day,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Switch(
                      value: hours.isOpen,
                      onChanged: (value) {
                        // TODO: Mettre à jour les horaires
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                if (hours.isOpen) ...[
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          'Ouverture',
                          hours.openTime ?? '',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTimeField(
                          'Fermeture',
                          hours.closeTime ?? '',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pause déjeuner',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      Switch(
                        value: hours.hasLunchBreak,
                        onChanged: (value) {
                          // TODO: Mettre à jour la pause déjeuner
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (hours.hasLunchBreak) ...[
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            'Début',
                            hours.lunchStart ?? '',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTimeField(
                            'Fin',
                            hours.lunchEnd ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Réservation en ligne',
            [
              _buildSwitchField(
                'Autoriser la réservation en ligne',
                settings.allowOnlineBooking,
                Icons.calendar_today,
              ),
              SizedBox(height: 16.h),
              _buildNumberField(
                'Durée par défaut (minutes)',
                settings.defaultAppointmentDuration.toString(),
                Icons.timer,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSection(
            'Acompte',
            [
              _buildSwitchField(
                'Demander un acompte',
                settings.requireDeposit,
                Icons.payment,
              ),
              if (settings.requireDeposit) ...[
                SizedBox(height: 16.h),
                _buildNumberField(
                  'Montant de l\'acompte',
                  settings.depositAmount?.toString() ?? '',
                  Icons.euro,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Notifications',
            [
              _buildSwitchField(
                'Activer les notifications',
                settings.enableNotifications,
                Icons.notifications,
              ),
              SizedBox(height: 16.h),
              _buildSwitchField(
                'SMS',
                settings.enableSMS,
                Icons.sms,
              ),
              SizedBox(height: 16.h),
              _buildSwitchField(
                'Emails',
                settings.enableEmails,
                Icons.email,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 16.h),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    IconData icon, {
    bool optional = false,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        suffixText: optional ? 'Optionnel' : null,
        suffixStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          // TODO: Mettre à jour l'heure
        }
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: (newValue) {
        // TODO: Mettre à jour la valeur
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, String value, IconData icon) {
    return TextField(
      controller: TextEditingController(text: value),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildSwitchField(String label, bool value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.text,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            // TODO: Mettre à jour la valeur
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
