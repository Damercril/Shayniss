import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shayniss/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final String professionalId;

  const ProfessionalProfileScreen({
    Key? key,
    required this.professionalId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil du prestataire'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec photo de profil
            Container(
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.1),
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Hero(
                    tag: 'professional_avatar_$professionalId',
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundImage: const AssetImage('assets/images/default_avatar.png'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Sarah Martin', // À remplacer par les données du prestataire
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Coiffeuse professionnelle', // À remplacer par les données du prestataire
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatistic('4.8', 'Note moyenne'),
                      SizedBox(width: 32.w),
                      _buildStatistic('127', 'Prestations'),
                      SizedBox(width: 32.w),
                      _buildStatistic('2 ans', 'Expérience'),
                    ],
                  ),
                ],
              ),
            ),
            
            // À propos
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Passionnée par la coiffure depuis plus de 2 ans, je vous propose mes services à domicile. Spécialisée dans les coupes modernes et les colorations, je m\'adapte à vos envies pour vous offrir le meilleur résultat.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  Text(
                    'Services proposés',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildServiceCard(
                    'Coupe femme',
                    '45€',
                    '45 min',
                    'Coupe, brushing et conseils personnalisés',
                  ),
                  SizedBox(height: 12.h),
                  _buildServiceCard(
                    'Coloration',
                    '65€',
                    '1h30',
                    'Coloration professionnelle avec soins',
                  ),
                  
                  SizedBox(height: 24.h),
                  Text(
                    'Galerie photos',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 120.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildGalleryImage('https://images.unsplash.com/photo-1560869713-da86a9ec4623', context),
                        _buildGalleryImage('https://images.unsplash.com/photo-1562322140-8baeececf3df', context),
                        _buildGalleryImage('https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f', context),
                        _buildGalleryImage('https://images.unsplash.com/photo-1522337360788-8b13dee7a37e', context),
                        _buildGalleryImage('https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1', context),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  Text(
                    'Avis clients',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildReviewCard(
                    'Marie L.',
                    5,
                    'Excellent service ! Sarah est très professionnelle et à l\'écoute.',
                    '2 jours',
                  ),
                  SizedBox(height: 12.h),
                  _buildReviewCard(
                    'Sophie D.',
                    4,
                    'Très satisfaite de ma coupe, je recommande !',
                    '1 semaine',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton(
            onPressed: () {
              // Navigation vers la page de réservation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'Prendre rendez-vous',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(String name, String price, String duration, String description) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 16.sp,
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
                Icons.schedule,
                size: 16.w,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(String imageUrl, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewGallery.builder(
                itemCount: 5, // Nombre total d'images
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                      [
                        'https://images.unsplash.com/photo-1560869713-da86a9ec4623',
                        'https://images.unsplash.com/photo-1562322140-8baeececf3df',
                        'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f',
                        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e',
                        'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1',
                      ][index],
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: PageController(initialPage: 0),
              ),
            ),
          );
        },
        child: Hero(
          tag: imageUrl,
          child: Container(
            width: 120.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 24.w,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(String name, int rating, String comment, String timeAgo) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Il y a $timeAgo',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: AppColors.primary,
                size: 16.w,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
