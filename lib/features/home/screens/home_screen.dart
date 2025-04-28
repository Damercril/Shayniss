import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/service_category.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../appointments/services/appointment_service.dart';
import '../../appointments/models/appointment.dart';
import 'package:shayniss/core/widgets/error_handling_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  final AppointmentService _appointmentService = AppointmentService();
  List<ServiceCategory> _categories = [];
  List<Appointment> _upcomingAppointments = [];
  bool _isLoading = true;
  
  // Pour gérer les likes des posts
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCount = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      await Future.wait([
        _loadCategories(),
        _loadAppointments(),
      ]);
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() => _categories = categories);
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await _appointmentService.getUpcomingAppointments();
      setState(() => _upcomingAppointments = appointments);
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }
  
  // Fonction pour gérer les likes
  void _toggleLike(String postId, String initialLikes) {
    setState(() {
      // Inverser l'état du like
      _likedPosts[postId] = !(_likedPosts[postId] ?? false);
      
      // Mettre à jour le compteur de likes
      if (_likedPosts[postId] ?? false) {
        _likesCount[postId] = (_likesCount[postId] ?? int.parse(initialLikes)) + 1;
      } else {
        _likesCount[postId] = (_likesCount[postId] ?? int.parse(initialLikes)) - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: CommonAppBar(
                      title: 'Shayniss',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildServicesSection(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildUpcomingAppointments(),
                  ),
                  
                  // Feed
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Text(
                        'Actualités du secteur',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildFeedPost(
                        username: 'Association Française des Esthéticiennes',
                        userImage: 'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=400',
                        postImage: 'https://images.pexels.com/photos/3997993/pexels-photo-3997993.jpeg?auto=compress&cs=tinysrgb&w=800',
                        description: 'Nouvelles tendances 2025 : Les soins naturels et bio sont en forte demande ! 🌿\nDécouvrez notre guide complet pour adapter votre offre.',
                        likes: '245',
                        timeAgo: '1j',
                        rating: '4.9',
                        reviewCount: '320',
                      ),
                      _buildFeedPost(
                        username: 'Salon International de la Beauté',
                        userImage: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
                        postImage: 'https://images.pexels.com/photos/3985338/pexels-photo-3985338.jpeg?auto=compress&cs=tinysrgb&w=800',
                        description: 'Le salon 2025 ouvre ses portes le mois prochain ! 📅\nInscrivez-vous dès maintenant pour présenter vos services et rencontrer de nouveaux clients.',
                        likes: '189',
                        timeAgo: '2j',
                        rating: '4.7',
                        reviewCount: '156',
                      ),
                      _buildFeedPost(
                        username: 'Formation Professionnelle Beauté',
                        userImage: 'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
                        postImage: 'https://images.pexels.com/photos/3373716/pexels-photo-3373716.jpeg?auto=compress&cs=tinysrgb&w=800',
                        description: 'Nouvelle certification en microblading disponible ! 🔍\nFormation en ligne ou en présentiel, places limitées.',
                        likes: '112',
                        timeAgo: '3j',
                        rating: '4.6',
                        reviewCount: '89',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildServicesSection() {
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Nos services',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _buildServiceItem(_categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceCategory category) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(category.icon),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochains rendez-vous',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16.h),
          if (_upcomingAppointments.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  'Aucun rendez-vous à venir',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _upcomingAppointments.length,
              itemBuilder: (context, index) {
                return _buildAppointmentCard(_upcomingAppointments[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.formattedDateTime,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${appointment.serviceName} avec ${appointment.professionalName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Méthode pour construire un post du feed
  Widget _buildFeedPost({
    required String username,
    required String userImage,
    required String postImage,
    required String description,
    required String likes,
    required String timeAgo,
    String rating = "4.8",
    String reviewCount = "124",
  }) {
    // Générer un ID unique pour le post basé sur ses propriétés
    final String postId = '$username-$timeAgo';
    
    // Initialiser le compteur de likes si nécessaire
    if (!_likesCount.containsKey(postId)) {
      _likesCount[postId] = int.parse(likes);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: ErrorHandlingImage(
                      imageUrl: userImage,
                      width: 40.r,
                      height: 40.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "$rating ($reviewCount avis)",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image du post
          Container(
            width: double.infinity,
            height: 200.h,
            child: CachedNetworkImage(
              imageUrl: postImage,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 50.w,
                ),
              ),
              fit: BoxFit.cover,
            ),
          ),

          // Actions et description
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleLike(postId, likes),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              (_likedPosts[postId] ?? false) 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                              key: ValueKey<bool>(_likedPosts[postId] ?? false),
                              size: 24.w,
                              color: (_likedPosts[postId] ?? false) 
                                ? Colors.red 
                                : Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _likesCount[postId].toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.comment_outlined,
                            size: 22.w,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.share_outlined,
                            size: 22.w,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.bookmark_border,
                            size: 22.w,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
