import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../models/category.dart';
import '../models/provider.dart';

class ClientMapScreen extends StatefulWidget {
  const ClientMapScreen({super.key});

  @override
  State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(48.8566, 2.3522);
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  String _selectedCategory = '';
  double _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation, 15);
    } catch (e) {
      debugPrint('Erreur de géolocalisation: $e');
    }
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchExpanded ? 500.h : 60.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onTap: () => setState(() => _isSearchExpanded = true),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un prestataire, un service...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: AppColors.primary,
                  ),
                  onPressed: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
                ),
              ],
            ),
          ),
          if (_isSearchExpanded) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1),
                    // Catégories
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catégories',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 110.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: demoCategories.length,
                              itemBuilder: (context, index) {
                                final category = demoCategories[index];
                                final isSelected = _selectedCategory == category.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = isSelected ? '' : category.id;
                                    });
                                  },
                                  child: Container(
                                    width: 100.w,
                                    margin: EdgeInsets.only(right: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 70.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.r),
                                            image: DecorationImage(
                                              image: AssetImage(category.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${category.serviceCount} services',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    // Prestataires populaires
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prestataires populaires',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...demoProviders.map((provider) => Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Images des services
                                SizedBox(
                                  height: 120.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: provider.photoUrls.length,
                                    itemBuilder: (context, index) => Container(
                                      width: 120.w,
                                      margin: EdgeInsets.only(right: index != provider.photoUrls.length - 1 ? 8.w : 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        image: DecorationImage(
                                          image: AssetImage(provider.photoUrls[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            provider.name,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.star, color: Colors.amber, size: 18.w),
                                              SizedBox(width: 4.w),
                                              Text(
                                                provider.rating.toString(),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                ' (${provider.reviewCount})',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, color: AppColors.primary, size: 16.w),
                                          SizedBox(width: 4.w),
                                          Text(
                                            provider.location,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children: provider.categories.map((category) => Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        )).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Carte',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => setState(() => _isSearchExpanded = false),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 13.0,
                maxZoom: 18.0,
                minZoom: 3.0,
                interactionOptions: InteractionOptions(
                  enableScrollWheel: true,
                  enableMultiFingerGestureRace: true,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.shayniss.app',
                  tileBuilder: (context, tileWidget, tile) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: tileWidget,
                    );
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Barre de recherche améliorée
            Positioned(
              top: 16.h,
              left: 0,
              right: 0,
              child: _buildSearchBar(),
            ),
            // Boutons de zoom
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoomIn',
                    mini: true,
                    onPressed: () {
                      final newZoom = _mapController.zoom + 1;
                      if (newZoom <= 18) {
                        _mapController.move(_currentLocation, newZoom);
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.add, color: AppColors.primary),
                  ),
                  SizedBox(height: 8.h),
                  FloatingActionButton(
                    heroTag: 'zoomOut',
                    mini: true,
                    onPressed: () {
                      final newZoom = _mapController.zoom - 1;
                      if (newZoom >= 3) {
                        _mapController.move(_currentLocation, newZoom);
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.remove, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
