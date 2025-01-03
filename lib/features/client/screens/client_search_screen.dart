import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/category.dart';
import '../models/provider.dart';
import 'provider_details_screen.dart';

class ClientSearchScreen extends StatefulWidget {
  const ClientSearchScreen({super.key});

  @override
  State<ClientSearchScreen> createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends State<ClientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  double _selectedRating = 0;

  List<ServiceProvider> _getFilteredProviders() {
    if (_selectedCategory.isEmpty) {
      return demoProviders;
    }
    final category = demoCategories.firstWhere((cat) => cat.id == _selectedCategory);
    return demoProviders.where((provider) => 
      provider.categories.contains(category.name)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProviders = _getFilteredProviders();
    final selectedCategory = _selectedCategory.isNotEmpty 
      ? demoCategories.firstWhere((cat) => cat.id == _selectedCategory)
      : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Barre de recherche flottante avec retour si catégorie sélectionnée
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 60.h,
            leading: selectedCategory != null
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _selectedCategory = '';
                    });
                  },
                )
              : null,
            flexibleSpace: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ).copyWith(
                left: selectedCategory != null ? 56.w : 16.w,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: selectedCategory != null 
                      ? 'Rechercher dans ${selectedCategory.name}'
                      : 'Rechercher un service, un prestataire...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.tune, color: AppColors.primary),
                      onPressed: () {
                        // TODO: Ouvrir les filtres
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                ),
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégories horizontales (seulement si aucune catégorie sélectionnée)
                  if (selectedCategory == null) ...[
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 110.h,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: demoCategories.length,
                        itemBuilder: (context, index) {
                          final category = demoCategories[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category.id;
                              });
                            },
                            child: Container(
                              width: 100.w,
                              margin: EdgeInsets.only(right: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      image: DecorationImage(
                                        image: NetworkImage(category.imageUrl),
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
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // En-tête des résultats
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCategory != null 
                            ? 'Prestataires ${selectedCategory.name}'
                            : 'Prestataires populaires',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedCategory != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              '${filteredProviders.length} prestataires disponibles',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),
                        
                        // Liste des prestataires
                        ...filteredProviders.map((provider) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProviderDetailsScreen(
                                  provider: provider,
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                                  height: 150.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: provider.photoUrls.length,
                                    itemBuilder: (context, index) => Container(
                                      width: 150.w,
                                      margin: EdgeInsets.only(
                                        right: index != provider.photoUrls.length - 1 ? 8.w : 0
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        image: DecorationImage(
                                          image: NetworkImage(provider.photoUrls[index]),
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
      ),
    );
  }
}
