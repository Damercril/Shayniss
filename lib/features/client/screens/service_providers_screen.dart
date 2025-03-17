import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/service_filters_widget.dart';
import 'provider_profile_screen.dart';
import '../../../features/appointments/widgets/booking_form_modal.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final String serviceType;

  const ServiceProvidersScreen({
    Key? key,
    required this.serviceType,
  }) : super(key: key);

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  final Map<String, dynamic> _filters = {
    'distance': 10.0,
    'minPrice': 0.0,
    'maxPrice': 200.0,
    'minRating': 0,
    'availableNow': false,
  };

  final List<Map<String, dynamic>> _providers = [
    {
      'id': 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      'name': 'Sarah Martin',
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200',
      'rating': 4.8,
      'reviews': 127,
      'distance': 2.3,
      'price': 65,
      'available': true,
    },
    {
      'id': 'b9c24b3f-6f23-4c8e-a84c-4e36e52d5c2b',
      'name': 'Marie Dubois',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
      'rating': 4.5,
      'reviews': 89,
      'distance': 3.7,
      'price': 55,
      'available': false,
    },
    {
      'id': 'd5f39c8e-2a1d-4cd5-b726-9e4c1f5e8c3a',
      'name': 'Julie Bernard',
      'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200',
      'rating': 4.9,
      'reviews': 156,
      'distance': 1.5,
      'price': 75,
      'available': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredProviders {
    return _providers.where((provider) {
      if (_filters['availableNow'] && !provider['available']) {
        return false;
      }
      if (provider['distance'] > _filters['distance']) {
        return false;
      }
      if (provider['price'] < _filters['minPrice'] || 
          provider['price'] > _filters['maxPrice']) {
        return false;
      }
      if (provider['rating'] < _filters['minRating']) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a['distance'].compareTo(b['distance']));
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceFiltersWidget(
        currentFilters: _filters,
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters.addAll(newFilters);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.serviceType,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppColors.primary,
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Prestataires à proximité',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                Text(
                  '${_filteredProviders.length} résultats',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _filteredProviders.length,
              itemBuilder: (context, index) {
                final provider = _filteredProviders[index];
                return _buildProviderCard(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderProfileScreen(
                    provider: {
                      ...provider,
                      'coverImage': 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=2000',
                    },
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: provider['image'],
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (provider['available'])
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Disponible',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider['name'],
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider['price']}€',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      provider['rating'].toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' (${provider['reviews']} avis)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${provider['distance']} km',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BookingFormModal(
                        providerFirstName: provider['name'].split(' ')[0],
                        providerLastName: provider['name'].split(' ')[1],
                        serviceType: widget.serviceType,
                        initialPrice: provider['price'].toDouble(),
                        initialDuration: 60, // Durée par défaut en minutes
                        servicePhotoUrl: provider['image'],
                      ),
                    );
                  },
                  child: Text(
                    'Prendre rendez-vous',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
