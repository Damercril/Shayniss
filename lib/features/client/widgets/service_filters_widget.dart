import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class ServiceFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> currentFilters;

  const ServiceFiltersWidget({
    Key? key,
    required this.onFiltersChanged,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<ServiceFiltersWidget> createState() => _ServiceFiltersWidgetState();
}

class _ServiceFiltersWidgetState extends State<ServiceFiltersWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Distance',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _filters['distance'] ?? 10.0,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            label: '${_filters['distance']?.round() ?? 10} km',
            onChanged: (value) {
              setState(() {
                _filters['distance'] = value;
              });
              widget.onFiltersChanged(_filters);
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'Prix',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          RangeSlider(
            values: RangeValues(
              _filters['minPrice']?.toDouble() ?? 0.0,
              _filters['maxPrice']?.toDouble() ?? 200.0,
            ),
            min: 0.0,
            max: 200.0,
            divisions: 20,
            labels: RangeLabels(
              '${_filters['minPrice']?.round() ?? 0}€',
              '${_filters['maxPrice']?.round() ?? 200}€',
            ),
            onChanged: (values) {
              setState(() {
                _filters['minPrice'] = values.start;
                _filters['maxPrice'] = values.end;
              });
              widget.onFiltersChanged(_filters);
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'Note minimum',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < (_filters['minRating'] ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _filters['minRating'] = index + 1;
                  });
                  widget.onFiltersChanged(_filters);
                },
              );
            }),
          ),
          SizedBox(height: 16.h),
          Text(
            'Disponibilité',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SwitchListTile(
            title: Text('Disponible maintenant'),
            value: _filters['availableNow'] ?? false,
            onChanged: (value) {
              setState(() {
                _filters['availableNow'] = value;
              });
              widget.onFiltersChanged(_filters);
            },
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Appliquer les filtres',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
