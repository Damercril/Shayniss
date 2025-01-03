import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/provider.dart';
import '../../../features/appointments/widgets/booking_form_modal.dart';
import '../../../features/appointments/models/booking_details.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final ServiceProvider provider;

  const ProviderDetailsScreen({
    Key? key,
    required this.provider,
  }) : super(key: key);

  void _showReviewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avis clients',
                    style: TextStyle(
                      fontSize: 18.sp,
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
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5, // Exemple avec 5 avis
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-${500 + index}?fit=crop&w=50&h=50',
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Client ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        Icons.star,
                                        size: 16.w,
                                        color: starIndex < (5 - index % 2)
                                            ? Colors.amber
                                            : Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Super expérience ! Le service était impeccable et très professionnel.',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Il y a ${index + 1} jour${index == 0 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // En-tête avec images en carrousel
          SliverAppBar(
            expandedHeight: 300.h,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: AppColors.primary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: provider.photoUrls.length,
                itemBuilder: (context, index) => Image.network(
                  provider.photoUrls[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec nom et note
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.location_on, 
                                  color: AppColors.primary,
                                  size: 16.w,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  provider.location,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showReviewsDialog(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                provider.rating.toString(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              Text(
                                ' (${provider.reviewCount})',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Services proposés
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services proposés',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: provider.categories.map((category) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),

                // Description
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À propos',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Notre équipe de professionnels qualifiés vous accueille dans un cadre chaleureux et relaxant. Nous mettons notre expertise à votre service pour vous offrir une expérience unique et personnalisée.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Horaires
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horaires d\'ouverture',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildHourRow('Lundi - Vendredi', '9:00 - 20:00'),
                      _buildHourRow('Samedi', '10:00 - 18:00'),
                      _buildHourRow('Dimanche', 'Fermé'),
                    ],
                  ),
                ),

                SizedBox(height: 100.h), // Espace pour le bouton flottant
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(16.r),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final booking = await showModalBottomSheet<BookingDetails>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => BookingFormModal(
                providerFirstName: provider.name.split(' ').first,
                providerLastName: provider.name.split(' ').last,
                serviceType: provider.categories.first,
                servicePhotoUrl: provider.imageUrl,
                initialPrice: 50.0, // À personnaliser selon le service
                initialDuration: 60, // À personnaliser selon le service
              ),
            );

            if (booking != null) {
              // TODO: Sauvegarder la réservation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Réservation confirmée !'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          label: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Prendre rendez-vous',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
