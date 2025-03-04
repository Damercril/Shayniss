import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';

class LocationMapWidget extends StatefulWidget {
  final void Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;

  const LocationMapWidget({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? LatLng(48.8566, 2.3522); // Paris par défaut
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300.h,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 13.0,
                maxZoom: 18.0,
                minZoom: 3.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                    widget.onLocationSelected(point);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.shayniss.app',
                  tileBuilder: (context, widget, tile) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: widget,
                    );
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
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
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.my_location),
              onPressed: () async {
                try {
                  final position = await Geolocator.getCurrentPosition();
                  final newLocation = LatLng(position.latitude, position.longitude);
                  setState(() {
                    _selectedLocation = newLocation;
                  });
                  _mapController.move(_selectedLocation, 15.0);
                  widget.onLocationSelected(_selectedLocation);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Impossible d\'obtenir votre position')),
                    );
                  }
                }
              },
            ),
            SizedBox(width: 8.w),
            IconButton(
              icon: Icon(Icons.zoom_in),
              onPressed: () async {
                final currentZoom = _mapController.camera.zoom;
                final newZoom = currentZoom + 1;
                if (newZoom <= 18) {
                  _mapController.move(_selectedLocation, newZoom);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.zoom_out),
              onPressed: () async {
                final currentZoom = _mapController.camera.zoom;
                final newZoom = currentZoom - 1;
                if (newZoom >= 3) {
                  _mapController.move(_selectedLocation, newZoom);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
