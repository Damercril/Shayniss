import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
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
  final SupabaseClient supabase = SupabaseService.client;
  bool _isLoading = true;
  String? _error;

  final Map<String, dynamic> _filters = {
    'distance': 10.0,
    'minPrice': 0.0,
    'maxPrice': 200.0,
    'minRating': 0,
    'availableNow': false,
  };

  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('Loading providers for category: ${widget.serviceType}');

      // D'abord, récupérons la catégorie sans tenir compte de la casse
      final categoriesResponse = await supabase
          .from('service_categories')
          .select('id, name')
          .ilike('name', widget.serviceType);

      print('Categories response: $categoriesResponse');

      if (categoriesResponse == null || categoriesResponse.isEmpty) {
        throw Exception('Category not found: ${widget.serviceType}');
      }

      final categoryId = categoriesResponse[0]['id'];

      // Ensuite, récupérons les professionnels de cette catégorie
      final response = await supabase
          .from('professionals')
          .select('''
            *,
            services!inner (
              id,
              name,
              description,
              price,
              duration,
              category_id
            )
          ''')
          .eq('services.category_id', categoryId)
          .eq('is_available', true)
          .order('rating', ascending: false);

      print('Response from Supabase: $response');

      setState(() {
        _providers = List<Map<String, dynamic>>.from(response);
        print('Providers after setState: $_providers');
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading providers: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger la liste des prestataires: $e';
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProviders {
    final filtered = _providers.where((provider) {
      if (_filters['availableNow'] && !(provider['is_available'] ?? false)) {
        return false;
      }
      if (provider['rating'] != null && 
          provider['rating'] < _filters['minRating']) {
        return false;
      }
      return true;
    }).toList();
    
    print('Filtered providers: $filtered');
    return filtered;
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48.w,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: _loadProviders,
                        icon: Icon(Icons.refresh),
                        label: Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredProviders.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun prestataire disponible pour le moment',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Column(
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
                      'coverImage': 'https://images.pexels.com/photos/3997989/pexels-photo-3997989.jpeg',
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
                    imageUrl: provider['profile_picture_url'] ?? 'https://images.pexels.com/photos/3997989/pexels-photo-3997989.jpeg',
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 200.h,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.grey[500]),
                    ),
                  ),
                ),
                if (provider['is_available'])
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
                      provider['name'] ?? 'Nom inconnu',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'À partir de ${provider['services']?[0]?['price'] ?? '??'}€',
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
                      (provider['rating'] ?? '0.0').toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' (${provider['review_count'] ?? 0} avis)',
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
                        initialPrice: provider['services']?[0]?['price'] ?? 0.0,
                        initialDuration: 60, // Durée par défaut en minutes
                        servicePhotoUrl: provider['profile_picture_url'],
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
