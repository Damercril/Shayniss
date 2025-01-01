import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class AdvancedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onFilterChange;

  const AdvancedSearchBar({
    Key? key,
    required this.onSearch,
    required this.onFilterChange,
  }) : super(key: key);

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 200);
  String _selectedDuration = 'Tous';
  String _selectedCategory = 'Toutes';

  final List<String> _durations = [
    'Tous',
    '30 min',
    '1h',
    '1h30',
    '2h+',
  ];

  final List<String> _categories = [
    'Toutes',
    'Coiffure',
    'Manucure',
    'Maquillage',
    'Soins',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearch,
            decoration: InputDecoration(
              hintText: 'Rechercher un service...',
              border: InputBorder.none,
              icon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Tags de filtres rapides
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Populaires', true),
              _buildFilterChip('Promotions', false),
              _buildFilterChip('Nouveautés', false),
              _buildFilterChip('Favoris', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (bool selected) {
          // TODO: Implémenter la logique de filtrage
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtres',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text('Prix'),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 200,
              divisions: 20,
              labels: RangeLabels(
                '${_priceRange.start.round()}€',
                '${_priceRange.end.round()}€',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
                _updateFilters();
              },
            ),
            SizedBox(height: 16.h),
            Text('Durée'),
            Wrap(
              spacing: 8.w,
              children: _durations
                  .map((duration) => ChoiceChip(
                        label: Text(duration),
                        selected: _selectedDuration == duration,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedDuration = selected ? duration : 'Tous';
                          });
                          _updateFilters();
                        },
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Text('Catégorie'),
            Wrap(
              spacing: 8.w,
              children: _categories
                  .map((category) => ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'Toutes';
                          });
                          _updateFilters();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFilters() {
    widget.onFilterChange({
      'priceRange': _priceRange,
      'duration': _selectedDuration,
      'category': _selectedCategory,
    });
  }
}
