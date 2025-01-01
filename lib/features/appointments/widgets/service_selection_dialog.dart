import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class ServiceSelectionDialog extends StatefulWidget {
  const ServiceSelectionDialog({Key? key}) : super(key: key);

  @override
  State<ServiceSelectionDialog> createState() => _ServiceSelectionDialogState();
}

class _ServiceSelectionDialogState extends State<ServiceSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 0.9.sw,
        height: 0.7.sh,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // En-tête
            Row(
              children: [
                Text(
                  'Sélectionner un service',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16.h),

            // Catégories
            SizedBox(
              height: 40.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'Tous',
                  'Coupe',
                  'Coloration',
                  'Coiffure',
                  'Soin',
                  'Autres',
                ].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.text,
                          fontSize: 14.sp,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.h),

            // Liste des services
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            size: 48.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Aucun service trouvé',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredServices = snapshot.data!
                      .where((service) =>
                          (_selectedCategory == 'Tous' ||
                              service['category'] == _selectedCategory) &&
                          (service['name']
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              service['description']
                                  .toLowerCase()
                                  .contains(_searchQuery)))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12.w),
                          leading: Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.spa_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            service['name'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.h),
                              Text(
                                service['description'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 16.w,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    service['duration'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Icon(
                                    Icons.euro_outlined,
                                    size: 16.w,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${service['price']}€',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => Navigator.pop(context, service),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getServices() async {
    // TODO: Récupérer les vrais services depuis la base de données
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'id': '1',
        'name': 'Coupe Femme',
        'description': 'Coupe, shampoing et brushing',
        'category': 'Coupe',
        'duration': '1h00',
        'price': 45,
      },
      {
        'id': '2',
        'name': 'Coloration',
        'description': 'Coloration complète avec soin',
        'category': 'Coloration',
        'duration': '2h00',
        'price': 65,
      },
      {
        'id': '3',
        'name': 'Brushing',
        'description': 'Shampoing et brushing',
        'category': 'Coiffure',
        'duration': '45min',
        'price': 35,
      },
      {
        'id': '4',
        'name': 'Soin profond',
        'description': 'Soin réparateur avec massage',
        'category': 'Soin',
        'duration': '30min',
        'price': 25,
      },
    ];
  }
}
