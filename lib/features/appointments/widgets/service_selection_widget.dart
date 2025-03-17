import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../services/service_database_service.dart';
import '../models/service_model.dart';
import '../exceptions/service_validation_exception.dart';
import '../exceptions/service_database_exception.dart';
import './booking_form_modal.dart';
import '../../client/screens/client_chat_screen.dart';

class _Debouncer {
  final Duration delay;
  Timer? _timer;

  _Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

class ServiceSelectionWidget extends StatelessWidget {
  final Map<String, dynamic> provider;
  final void Function(ServiceModel) onServiceSelected;

  const ServiceSelectionWidget({
    Key? key,
    required this.provider,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Sélectionnez un service',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _ServiceSelectionWidgetContent(
              provider: provider,
              onServiceSelected: onServiceSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSelectionWidgetContent extends StatefulWidget {
  final Map<String, dynamic> provider;
  final void Function(ServiceModel) onServiceSelected;

  const _ServiceSelectionWidgetContent({
    Key? key,
    required this.provider,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  _ServiceSelectionWidgetContentState createState() => _ServiceSelectionWidgetContentState();
}

class _ServiceSelectionWidgetContentState extends State<_ServiceSelectionWidgetContent> {
  final ServiceDatabaseService _serviceService = ServiceDatabaseService();
  final _Debouncer _debouncer = _Debouncer();
  final TextEditingController _searchController = TextEditingController();

  List<ServiceModel> _services = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _loadingServices = true;
  String _searchQuery = '';
  RangeValues _priceRange = RangeValues(0, 1000);
  RangeValues _durationRange = RangeValues(0, 240);
  String _sortOption = 'name';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() => _loadingServices = true);

    try {
      final services = await _serviceService.getServicesByProfessionalId(widget.provider['professional_id']);
      
      if (!mounted) return;

      // Calculate ranges from actual data
      if (services.isNotEmpty) {
        final prices = services.map((s) => s.price).toList();
        final durations = services.map((s) => s.durationMinutes.toDouble()).toList();
        _priceRange = RangeValues(
          prices.reduce(math.min),
          prices.reduce(math.max),
        );
        _durationRange = RangeValues(
          durations.reduce(math.min),
          durations.reduce(math.max),
        );
      }

      // Extract unique categories
      final categories = services
          .map((s) => s.category)
          .where((c) => c != null)
          .map((c) => c!)
          .toSet()
          .toList();

      setState(() {
        _services = services;
        _categories = categories;
        _loadingServices = false;
      });
    } on ServiceValidationException catch (e) {
      if (!mounted) return;
      setState(() => _loadingServices = false);
      _showErrorSnackBar(e.toString(), Colors.orange, _loadServices);
    } on ServiceDatabaseException catch (e) {
      if (!mounted) return;
      setState(() => _loadingServices = false);
      _showErrorSnackBar(e.toString(), Colors.red, _loadServices);
    }
  }

  void _showErrorSnackBar(String message, Color backgroundColor, VoidCallback onRetry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
      ),
    );
  }

  Future<void> _searchServices() async {
    if (!mounted || _loadingServices) return;
    setState(() => _loadingServices = true);

    try {
      final services = await _serviceService.searchServices(
        query: _searchQuery,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        minDuration: _durationRange.start.toInt(),
        maxDuration: _durationRange.end.toInt(),
        category: _selectedCategory,
        professionalId: widget.provider['professional_id'],
      );

      if (!mounted) return;
      setState(() {
        _services = services;
        _loadingServices = false;
      });
    } on ServiceValidationException catch (e) {
      if (!mounted) return;
      setState(() => _loadingServices = false);
      _showErrorSnackBar(e.toString(), Colors.orange, _searchServices);
    } on ServiceDatabaseException catch (e) {
      if (!mounted) return;
      setState(() => _loadingServices = false);
      _showErrorSnackBar(e.toString(), Colors.red, _searchServices);
    }
  }

  List<ServiceModel> get _filteredAndSortedServices {
    var services = List<ServiceModel>.from(_services);

    switch (_sortOption) {
      case 'price':
        services.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'duration':
        services.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
      case 'popularity':
        services.sort((a, b) => b.bookingCount.compareTo(a.bookingCount));
        break;
      default: // 'name'
        services.sort((a, b) => a.name.compareTo(b.name));
    }

    return services;
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _debouncer.run(_searchServices);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.secondary.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Catégories
                  if (_categories.isNotEmpty) ...[
                    Text(
                      'Catégories',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        FilterChip(
                          selected: _selectedCategory == null,
                          label: Text('Tous'),
                          onSelected: (selected) {
                            setState(() => _selectedCategory = null);
                          },
                          backgroundColor: Colors.white.withOpacity(0.1),
                          selectedColor: Colors.white.withOpacity(0.3),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: _selectedCategory == null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        ..._categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return FilterChip(
                            selected: isSelected,
                            label: Text(category),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            },
                            backgroundColor: Colors.white.withOpacity(0.1),
                            selectedColor: Colors.white.withOpacity(0.3),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Prix
                  Text(
                    'Prix (€)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_priceRange.start.toStringAsFixed(0)}€',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${_priceRange.end.toStringAsFixed(0)}€',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    labels: RangeLabels(
                      '${_priceRange.start.toStringAsFixed(0)}€',
                      '${_priceRange.end.toStringAsFixed(0)}€',
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Durée
                  Text(
                    'Durée (minutes)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_durationRange.start.toStringAsFixed(0)} min',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${_durationRange.end.toStringAsFixed(0)} min',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _durationRange,
                    min: 0,
                    max: 240,
                    divisions: 24,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    labels: RangeLabels(
                      '${_durationRange.start.toStringAsFixed(0)} min',
                      '${_durationRange.end.toStringAsFixed(0)} min',
                    ),
                    onChanged: (values) {
                      setState(() => _durationRange = values);
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _priceRange = RangeValues(0, 1000);
                              _durationRange = RangeValues(0, 240);
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              side: BorderSide(color: Colors.white24),
                            ),
                          ),
                          child: Text('Réinitialiser'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (mounted) {
                              this.setState(() {});
                              _searchServices();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.9),
                AppColors.secondary.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trier par',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildSortOption('name', 'Nom', Icons.sort_by_alpha),
              _buildSortOption('price', 'Prix', Icons.euro),
              _buildSortOption('duration', 'Durée', Icons.timer),
              _buildSortOption('popularity', 'Popularité', Icons.trending_up),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortOption == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _sortOption = value);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Spacer(),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20.r,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredAndSortedServices;
    final hasServices = services.isNotEmpty;

    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: ListTile(
            onTap: () => widget.onServiceSelected(service),
            title: Text(service.name),
            subtitle: Text('${service.durationMinutes} min • ${service.price}€'),
          ),
        );
      },
    );
  }
}
