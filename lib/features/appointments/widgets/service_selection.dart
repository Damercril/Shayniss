import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'service_image.dart';

class ServiceCategory {
  final String name;
  final List<Service> services;
  final IconData icon;

  ServiceCategory({
    required this.name,
    required this.services,
    required this.icon,
  });
}

class Service {
  final String name;
  final double price;
  final int durationMinutes;
  final String description;
  final String imageUrl;

  Service({
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.description,
    required this.imageUrl,
  });
}

class ServiceSelection extends StatefulWidget {
  final Function(List<Service>) onServicesSelected;

  const ServiceSelection({
    super.key,
    required this.onServicesSelected,
  });

  @override
  State<ServiceSelection> createState() => _ServiceSelectionState();
}

class _ServiceSelectionState extends State<ServiceSelection> {
  final List<ServiceCategory> categories = [
    ServiceCategory(
      name: 'Coiffure',
      icon: Icons.content_cut,
      services: [
        Service(
          name: 'Coupe femme',
          price: 35.0,
          durationMinutes: 60,
          description: 'Coupe, brushing et mise en forme',
          imageUrl: 'https://images.unsplash.com/photo-1560869713-da86a9ec94f6?w=500',
        ),
        Service(
          name: 'Coloration',
          price: 65.0,
          durationMinutes: 120,
          description: 'Coloration complète avec produits professionnels',
          imageUrl: 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=500',
        ),
        Service(
          name: 'Mèches',
          price: 85.0,
          durationMinutes: 150,
          description: 'Mèches ou balayage avec coupe et brushing',
          imageUrl: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=500',
        ),
      ],
    ),
    ServiceCategory(
      name: 'Soins',
      icon: Icons.spa,
      services: [
        Service(
          name: 'Soin profond',
          price: 45.0,
          durationMinutes: 45,
          description: 'Traitement nourrissant pour cheveux',
          imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500',
        ),
        Service(
          name: 'Massage crânien',
          price: 25.0,
          durationMinutes: 30,
          description: 'Massage relaxant du cuir chevelu',
          imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500',
        ),
      ],
    ),
    ServiceCategory(
      name: 'Coiffures',
      icon: Icons.face,
      services: [
        Service(
          name: 'Chignon',
          price: 55.0,
          durationMinutes: 60,
          description: 'Chignon de soirée ou mariage',
          imageUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e?w=500',
        ),
        Service(
          name: 'Brushing',
          price: 30.0,
          durationMinutes: 45,
          description: 'Brushing et mise en forme',
          imageUrl: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?w=500',
        ),
      ],
    ),
  ];

  List<Service> selectedServices = [];
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1EA),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isExpanded = expandedIndex == index;

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isExpanded ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              category.icon,
                              color: AppColors.primary,
                              size: 24.w,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  '${category.services.length} services',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: category.services.length,
                      itemBuilder: (context, serviceIndex) {
                        final service = category.services[serviceIndex];
                        final isSelected = selectedServices.contains(service);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedServices.remove(service);
                              } else {
                                selectedServices.add(service);
                              }
                              widget.onServicesSelected(selectedServices);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            margin: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              bottom: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                ServiceImage(
                                  imageUrl: service.imageUrl,
                                  width: 80,
                                  height: 80,
                                  borderRadius: 8,
                                  title: service.name,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        service.description,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16.w,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '${service.durationMinutes} min',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Icon(
                                            Icons.euro,
                                            size: 16.w,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '${service.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value ?? false) {
                                        selectedServices.add(service);
                                      } else {
                                        selectedServices.remove(service);
                                      }
                                      widget.onServicesSelected(selectedServices);
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
        if (selectedServices.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services sélectionnés',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...selectedServices.map((service) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '${service.price.toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Divider(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${selectedServices.fold<double>(0, (sum, service) => sum + service.price).toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
