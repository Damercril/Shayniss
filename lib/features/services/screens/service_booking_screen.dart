import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/service_booking_model.dart';
import '../widgets/booking_time_selector.dart';

class ServiceBookingScreen extends StatefulWidget {
  final String serviceId;

  const ServiceBookingScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  bool _homeService = false;
  String _paymentMethod = 'cash';
  bool _photoConsent = false;
  ServiceBooking? _service;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadService();
  }

  Future<void> _loadService() async {
    // TODO: Charger le service depuis Firebase
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Réserver ${_service?.serviceName ?? ''}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service details
              if (_service != null) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service!.serviceName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_service!.description != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          _service!.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.euro,
                            size: 16.w,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${_service!.price}€',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Icon(
                            Icons.timer,
                            size: 16.w,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${_service!.duration.inMinutes} min',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Informations client
              Text(
                'Vos informations',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom ou Prénom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro';
                  }
                  // TODO: Ajouter une validation plus stricte du numéro
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Sélection de la date et de l'heure
              Text(
                'Date et heure',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              BookingTimeSelector(
                onDateTimeSelected: (date, time) {
                  setState(() {
                    _selectedDate = date;
                    _selectedTime = time;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Options supplémentaires
              Text(
                'Options',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              if (_service?.homeService ?? false) ...[
                SwitchListTile(
                  title: const Text('Service à domicile'),
                  subtitle: const Text('Le prestataire se déplace chez vous'),
                  value: _homeService,
                  onChanged: (value) {
                    setState(() {
                      _homeService = value;
                    });
                  },
                ),
                SizedBox(height: 16.h),
              ],

              // Moyen de paiement
              Text(
                'Moyen de paiement préféré',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'cash',
                    label: Text('Espèces'),
                    icon: Icon(Icons.money),
                  ),
                  ButtonSegment(
                    value: 'card',
                    label: Text('Carte'),
                    icon: Icon(Icons.credit_card),
                  ),
                ],
                selected: {_paymentMethod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _paymentMethod = newSelection.first;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Consentement photo
              CheckboxListTile(
                title: const Text('J\'accepte d\'être pris(e) en photo pour les réseaux sociaux'),
                subtitle: const Text('Vous pourrez toujours refuser le jour J'),
                value: _photoConsent,
                onChanged: (value) {
                  setState(() {
                    _photoConsent = value ?? false;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Bouton de validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Confirmer la réservation',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
        ),
      );
      return;
    }

    // TODO: Envoyer la réservation à Firebase
    // TODO: Envoyer une notification au prestataire
    // TODO: Afficher une confirmation au client
  }
}
