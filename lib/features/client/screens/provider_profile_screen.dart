import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import './client_chat_screen.dart';
import './gallery_view_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de couverture et photo de profil
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de couverture
                  CachedNetworkImage(
                    imageUrl: widget.provider['coverImage'] ?? widget.provider['image'],
                    fit: BoxFit.cover,
                  ),
                  // Dégradé pour meilleure lisibilité
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Informations du prestataire
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -60.h),
              child: Column(
                children: [
                  // Photo de profil
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.provider['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Nom et badge de disponibilité
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.provider['name'],
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (widget.provider['available'])
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Disponible',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Note et avis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20.w),
                      SizedBox(width: 4.w),
                      Text(
                        widget.provider['rating'].toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${widget.provider['reviews']} avis)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Statistiques
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('Expérience', '5 ans'),
                        _buildStat('Clients', '500+'),
                        _buildStat('Prix/h', '${widget.provider['price']}€'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // À propos
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                        SizedBox(height: 8.h),
                        Text(
                          widget.provider['about'] ?? 'Professionnelle passionnée avec plus de 5 ans d\'expérience dans le domaine du bien-être. Spécialisée dans les massages relaxants et thérapeutiques, je m\'engage à offrir une expérience personnalisée et de qualité à chacun de mes clients.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Services proposés
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Services proposés',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ..._buildServices(),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Galerie photos
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Galerie photos',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GalleryViewScreen(
                                      imageUrls: const [
                                        'https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=800',
                                        'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?q=80&w=800',
                                        'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=800',
                                        'https://images.unsplash.com/photo-1542848284-8afa78a08ccb?q=80&w=800',
                                        'https://images.unsplash.com/photo-1515377905703-c4788e51af15?q=80&w=800',
                                        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=800',
                                        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=800',
                                        'https://images.unsplash.com/photo-1561049501-e1f96bdd98fd?q=80&w=800',
                                        'https://images.unsplash.com/photo-1590439471364-192aa70c0b53?q=80&w=800',
                                        'https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?q=80&w=800',
                                      ],
                                      initialIndex: 0,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Voir tout',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.h,
                          crossAxisSpacing: 8.w,
                          children: [
                            _buildGalleryImage('https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=800'),
                            _buildGalleryImage('https://images.unsplash.com/photo-1544161515-4ab6ce6db874?q=80&w=800'),
                            _buildGalleryImage('https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=800'),
                            _buildGalleryImage('https://images.unsplash.com/photo-1542848284-8afa78a08ccb?q=80&w=800'),
                            _buildGalleryImage('https://images.unsplash.com/photo-1515377905703-c4788e51af15?q=80&w=800'),
                            _buildGalleryImage('https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=800'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Réseaux sociaux
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: 'instagram',
                        url: widget.provider['instagram'] ?? 'https://instagram.com/sarahmassage',
                      ),
                      SizedBox(width: 16.w),
                      _buildSocialButton(
                        icon: 'tiktok',
                        url: widget.provider['tiktok'] ?? 'https://tiktok.com/@sarahmassage',
                      ),
                      SizedBox(width: 16.w),
                      _buildSocialButton(
                        icon: 'facebook',
                        url: widget.provider['facebook'] ?? 'https://facebook.com/sarahmassage',
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Bouton de chat
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientChatScreen(
                              name: widget.provider['name'],
                              imageUrl: widget.provider['image'],
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Envoyer un message',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Avis des clients
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avis des clients',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ..._buildReviews(),
                      ],
                    ),
                  ),
                  SizedBox(height: 100.h), // Espace pour le bouton flottant
                ],
              ),
            ),
          ),
        ],
      ),
      // Bouton de prise de rendez-vous flottant
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        width: double.infinity,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              // Navigation vers la page de réservation
            },
            child: Text(
              'Prendre rendez-vous',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStat(String label, String value) {
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
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildServices() {
    final List<Map<String, String>> services = [
      {'name': 'Massage relaxant', 'duration': '60 min', 'price': '65€'},
      {'name': 'Massage sportif', 'duration': '45 min', 'price': '55€'},
      {'name': 'Massage aux pierres chaudes', 'duration': '90 min', 'price': '85€'},
    ];

    return services.map((service) {
      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  service['duration']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              service['price']!,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSocialButton({required String icon, required String url}) {
    IconData getIconData() {
      switch (icon) {
        case 'instagram':
          return FontAwesomeIcons.instagram;
        case 'tiktok':
          return FontAwesomeIcons.tiktok;
        case 'facebook':
          return FontAwesomeIcons.facebook;
        default:
          return FontAwesomeIcons.link;
      }
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(
          getIconData(),
          color: AppColors.primary,
          size: 24.w,
        ),
        onPressed: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
      ),
    );
  }

  Widget _buildGalleryImage(String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryViewScreen(
              imageUrls: const [
                'https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=800',
                'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?q=80&w=800',
                'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?q=80&w=800',
                'https://images.unsplash.com/photo-1542848284-8afa78a08ccb?q=80&w=800',
                'https://images.unsplash.com/photo-1515377905703-c4788e51af15?q=80&w=800',
                'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=800',
                'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=800',
                'https://images.unsplash.com/photo-1561049501-e1f96bdd98fd?q=80&w=800',
                'https://images.unsplash.com/photo-1590439471364-192aa70c0b53?q=80&w=800',
                'https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?q=80&w=800',
              ],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        width: 150.w,
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(url),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReviews() {
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'Emma D.',
        'rating': 5,
        'comment': 'Excellent massage relaxant, très professionnelle !',
        'date': 'Il y a 2 jours'
      },
      {
        'name': 'Sophie M.',
        'rating': 4,
        'comment': 'Très bonne expérience, je recommande.',
        'date': 'Il y a 1 semaine'
      },
    ];

    return reviews.map((review) {
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['name'] as String,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (review['rating'] as int)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16.w,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              review['comment'] as String,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              review['date'] as String,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
