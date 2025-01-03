import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../models/booking_details.dart';
import 'location_map_widget.dart';

class BookingFormModal extends StatefulWidget {
  final String providerFirstName;
  final String providerLastName;
  final String serviceType;
  final String? servicePhotoUrl;
  final double initialPrice;
  final int initialDuration;

  const BookingFormModal({
    Key? key,
    required this.providerFirstName,
    required this.providerLastName,
    required this.serviceType,
    this.servicePhotoUrl,
    required this.initialPrice,
    required this.initialDuration,
  }) : super(key: key);

  @override
  State<BookingFormModal> createState() => _BookingFormModalState();
}

class _BookingFormModalState extends State<BookingFormModal> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isFlexibleTime = false;
  LocationType _locationType = LocationType.salon;
  String _clientAddress = '';
  String? _inspirationPhotoUrl;
  final List<String> _allergies = [];
  final List<String> _preferences = [];
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _acceptsPhotos = false;
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _preferenceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _allergyController.dispose();
    _preferenceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickInspirationPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // TODO: Upload image to storage and get URL
      setState(() {
        _inspirationPhotoUrl = image.path; // Temporary, should be cloud URL
      });
    }
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text);
        _allergyController.clear();
      });
    }
  }

  void _addPreference() {
    if (_preferenceController.text.isNotEmpty) {
      setState(() {
        _preferences.add(_preferenceController.text);
        _preferenceController.clear();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Les permissions de localisation sont désactivées de façon permanente'),
            action: SnackBarAction(
              label: 'Paramètres',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      // Obtenir la position actuelle
      final Position position = await Geolocator.getCurrentPosition();
      
      // Convertir les coordonnées en adresse avec un service de géocodage inverse
      // Pour l'instant, on affiche juste les coordonnées
      setState(() {
        _addressController.text = '${position.latitude}, ${position.longitude}';
        _clientAddress = _addressController.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération de la position')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.servicePhotoUrl != null
                        ? NetworkImage(widget.servicePhotoUrl!)
                        : null,
                    radius: 25.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.providerFirstName} ${widget.providerLastName}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.serviceType,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service details
                    Text(
                      'Détails du service',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                children: [
                                  Text('Durée'),
                                  Text(
                                    '${widget.initialDuration} min',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                children: [
                                  Text('Prix'),
                                  Text(
                                    '${widget.initialPrice.toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Date and Time
                    SizedBox(height: 16.h),
                    Text(
                      'Date et Heure',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 90)),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                  : 'Choisir une date',
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => _selectedTime = time);
                              }
                            },
                            icon: Icon(Icons.access_time),
                            label: Text(
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Choisir une heure',
                            ),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: _isFlexibleTime,
                      onChanged: (value) {
                        setState(() => _isFlexibleTime = value ?? false);
                      },
                      title: Text('Horaires flexibles'),
                    ),

                    // Location
                    SizedBox(height: 16.h),
                    Text(
                      'Lieu',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SegmentedButton<LocationType>(
                      segments: [
                        ButtonSegment<LocationType>(
                          value: LocationType.salon,
                          label: Text('Au salon'),
                          icon: Icon(Icons.store),
                        ),
                        ButtonSegment<LocationType>(
                          value: LocationType.client,
                          label: Text('À domicile'),
                          icon: Icon(Icons.home),
                        ),
                      ],
                      selected: {_locationType},
                      onSelectionChanged: (Set<LocationType> selection) {
                        setState(() {
                          _locationType = selection.first;
                          if (_locationType == LocationType.salon) {
                            _clientAddress = '';
                            _addressController.clear();
                          }
                        });
                      },
                    ),
                    if (_locationType == LocationType.client) ...[
                      SizedBox(height: 16.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Text(
                                'Sélectionnez votre emplacement',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            LocationMapWidget(
                              initialLocation: null,
                              onLocationSelected: (LatLng location) {
                                setState(() {
                                  _clientAddress = '${location.latitude}, ${location.longitude}';
                                  _addressController.text = _clientAddress;
                                });
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.r),
                              child: TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Votre adresse',
                                  hintText: 'Entrez votre adresse complète',
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                onChanged: (value) => _clientAddress = value,
                                validator: (value) {
                                  if (_locationType == LocationType.client &&
                                      (value == null || value.isEmpty)) {
                                    return 'Veuillez entrer votre adresse';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Photo d'inspiration
                    SizedBox(height: 16.h),
                    Text(
                      'Photo d\'inspiration (optionnel)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: _pickInspirationPhoto,
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _inspirationPhotoUrl != null
                            ? Image.network(_inspirationPhotoUrl!)
                            : Center(
                                child: Icon(
                                  Icons.add_photo_alternate,
                                  size: 40.w,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),

                    // Allergies
                    SizedBox(height: 16.h),
                    Text(
                      'Allergies',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _allergyController,
                            decoration: InputDecoration(
                              hintText: 'Ajouter une allergie',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addAllergy,
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.w,
                      children: _allergies
                          .map((e) => Chip(
                                label: Text(e),
                                onDeleted: () {
                                  setState(() => _allergies.remove(e));
                                },
                              ))
                          .toList(),
                    ),

                    // Préférences
                    SizedBox(height: 16.h),
                    Text(
                      'Préférences',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _preferenceController,
                            decoration: InputDecoration(
                              hintText: 'Ajouter une préférence',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addPreference,
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8.w,
                      children: _preferences
                          .map((e) => Chip(
                                label: Text(e),
                                onDeleted: () {
                                  setState(() => _preferences.remove(e));
                                },
                              ))
                          .toList(),
                    ),

                    // Mode de paiement
                    SizedBox(height: 16.h),
                    Text(
                      'Mode de paiement',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Column(
                      children: PaymentMethod.values.map((method) {
                        final isSelected = _paymentMethod == method;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: InkWell(
                            onTap: () {
                              setState(() => _paymentMethod = method);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  if (!isSelected)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.white 
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getPaymentIcon(method),
                                      color: isSelected 
                                          ? AppColors.primary 
                                          : Colors.grey.shade600,
                                      size: 20.w,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method.displayName,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected 
                                                ? Colors.white 
                                                : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          _getPaymentDescription(method),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: isSelected 
                                                ? Colors.white.withOpacity(0.8) 
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected 
                                        ? Icons.check_circle 
                                        : Icons.circle_outlined,
                                    color: isSelected 
                                        ? Colors.white 
                                        : Colors.grey.shade400,
                                    size: 24.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Photos
                    SizedBox(height: 16.h),
                    CheckboxListTile(
                      value: _acceptsPhotos,
                      onChanged: (value) {
                        setState(() => _acceptsPhotos = value ?? false);
                      },
                      title: Text('J\'accepte les photos (-5%)'),
                      subtitle: Text(
                        'Prix final: ${(_acceptsPhotos ? widget.initialPrice * 0.95 : widget.initialPrice).toStringAsFixed(2)}€',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null &&
                      _selectedTime != null) {
                    final booking = BookingDetails(
                      providerFirstName: widget.providerFirstName,
                      providerLastName: widget.providerLastName,
                      serviceType: widget.serviceType,
                      servicePhotoUrl: widget.servicePhotoUrl,
                      inspirationPhotoUrl: _inspirationPhotoUrl,
                      duration: widget.initialDuration,
                      price: widget.initialPrice,
                      date: _selectedDate!,
                      time: _selectedTime!,
                      isFlexibleTime: _isFlexibleTime,
                      locationType: _locationType,
                      clientAddress: _clientAddress,
                      salonAddress: _locationType == LocationType.salon
                          ? 'Adresse du salon' // TODO: Get from provider
                          : null,
                      allergies: _allergies,
                      preferences: _preferences,
                      paymentMethod: _paymentMethod,
                      acceptsPhotos: _acceptsPhotos,
                    );

                    Navigator.pop(context, booking);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text('Confirmer la réservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Paiement en espèces';
      case PaymentMethod.card:
        return 'Carte bancaire';
      case PaymentMethod.mobileMoney:
        return 'Paiement mobile';
      case PaymentMethod.transfer:
        return 'Virement bancaire';
      case PaymentMethod.paypal:
        return 'Paiement sécurisé';
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
      case PaymentMethod.transfer:
        return Icons.account_balance;
      case PaymentMethod.paypal:
        return Icons.paypal;
    }
  }
}
