import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import 'client_messages_screen.dart';
import '../services/message_service.dart';
import '../screens/service_providers_screen.dart';
import '../../../features/appointments/widgets/add_appointment_modal.dart';
import '../../../features/services/models/service.dart';
import '../../../features/appointments/widgets/booking_form_modal.dart';
import '../../../features/appointments/models/booking_details.dart';
import 'client_map_screen.dart';
import 'package:shayniss/core/widgets/error_handling_image.dart';
import '../widgets/service_search_delegate.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final Map<String, bool> _likedPosts = {};
  final Map<String, int> _likesCount = {};
  final MessageService _messageService = MessageService();

  // Liste des conversations pour compter les messages non lus
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Sarah Martin',
      'unread': 2,
    },
    {
      'name': 'Marie Dubois',
      'unread': 0,
    },
    {
      'name': 'Julie Bernard',
      'unread': 1,
    },
  ];

  // Calculer le nombre total de messages non lus
  int get _totalUnreadMessages => _conversations.fold(0, (sum, conv) => sum + (conv['unread'] as int));

  void _toggleLike(String postId, String currentLikes) {
    setState(() {
      // Initialiser le compteur si c'est le premier like
      if (!_likesCount.containsKey(postId)) {
        _likesCount[postId] = int.parse(currentLikes);
      }
      
      // Toggle like
      _likedPosts[postId] = !(_likedPosts[postId] ?? false);
      
      // Mettre à jour le compteur
      if (_likedPosts[postId]!) {
        _likesCount[postId] = _likesCount[postId]! + 1;
      } else {
        _likesCount[postId] = _likesCount[postId]! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Shayniss',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _messageService,
            builder: (context, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.message_outlined,
                      color: AppColors.primary,
                      size: 28.w,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClientMessagesScreen(),
                        ),
                      );
                    },
                  ),
                  if (_messageService.totalUnreadMessages > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.r,
                          minHeight: 16.r,
                        ),
                        child: Text(
                          _messageService.totalUnreadMessages.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 28.w,
            ),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Barre de recherche
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: GestureDetector(
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: ServiceSearchDelegate(),
                  );
                },
                child: Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.primary),
                      SizedBox(width: 12.w),
                      Text(
                        'Rechercher un service, un prestataire...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.tune, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Prestations
          SliverToBoxAdapter(
            child: Container(
              height: 100.h,
              margin: EdgeInsets.only(top: 8.h),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildServiceItem(
                    imageUrl: 'https://images.pexels.com/photos/3997993/pexels-photo-3997993.jpeg?auto=compress&cs=tinysrgb&w=200',
                    name: 'Massage',
                  ),
                  _buildServiceItem(
                    imageUrl: 'https://images.pexels.com/photos/3985338/pexels-photo-3985338.jpeg?auto=compress&cs=tinysrgb&w=200',
                    name: 'Coiffure',
                  ),
                  _buildServiceItem(
                    imageUrl: 'https://images.pexels.com/photos/3373716/pexels-photo-3373716.jpeg?auto=compress&cs=tinysrgb&w=200',
                    name: 'Manucure',
                  ),
                  _buildServiceItem(
                    imageUrl: 'https://images.pexels.com/photos/3997989/pexels-photo-3997989.jpeg?auto=compress&cs=tinysrgb&w=200',
                    name: 'Soin visage',
                  ),
                  _buildServiceItem(
                    imageUrl: 'https://images.pexels.com/photos/3997981/pexels-photo-3997981.jpeg?auto=compress&cs=tinysrgb&w=200',
                    name: 'Épilation',
                  ),
                ],
              ),
            ),
          ),

          // Feed
          SliverList(
            delegate: SliverChildListDelegate([
              _buildFeedPost(
                username: 'Sarah Martin',
                userImage: 'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=400',
                postImage: 'https://images.pexels.com/photos/5240677/pexels-photo-5240677.jpeg?auto=compress&cs=tinysrgb&w=800',
                description: 'Découvrez notre nouveau massage aux pierres chaudes ! 🌺✨\nUne expérience unique de détente profonde.',
                likes: '128',
                timeAgo: '2h',
                rating: '4.8',
                reviewCount: '124',
              ),
              _buildFeedPost(
                username: 'Marie Dubois',
                userImage: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
                postImage: 'https://images.pexels.com/photos/3764013/pexels-photo-3764013.jpeg?auto=compress&cs=tinysrgb&w=800',
                description: 'Offre spéciale soin du visage anti-âge ! 🎉\n-20% cette semaine sur notre soin signature.',
                likes: '95',
                timeAgo: '4h',
                rating: '4.5',
                reviewCount: '56',
              ),
              _buildFeedPost(
                username: 'Julie Bernard',
                userImage: 'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
                postImage: 'https://images.pexels.com/photos/3997379/pexels-photo-3997379.jpeg?auto=compress&cs=tinysrgb&w=800',
                description: 'Collection été : nouveaux vernis bio 💅\nDes couleurs vibrantes pour illuminer votre été !',
                likes: '156',
                timeAgo: '6h',
                rating: '4.9',
                reviewCount: '201',
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required String imageUrl,
    required String name,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceProvidersScreen(
              serviceType: name,
            ),
          ),
        );
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Container(
                    width: 100.w,
                    height: 70.w,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100.w,
                    height: 70.w,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.spa,
                      color: AppColors.primary,
                      size: 30.w,
                    ),
                  ),
                  width: 100.w,
                  height: 70.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                      GestureDetector(
                        onTap: () {
                          _showReviewsDialog(username, rating, reviewCount);
                        },
                        child: Row(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Image du post
          Container(
            width: double.infinity,
            height: 300.h,
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
                    TextButton.icon(
                      onPressed: () async {
                        final booking = await showModalBottomSheet<BookingDetails>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => BookingFormModal(
                            providerFirstName: username.split(' ').first,
                            providerLastName: username.split(' ').last,
                            serviceType: 'Service Beauté', // À personnaliser selon le post
                            servicePhotoUrl: postImage,
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
                      icon: Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20.w,
                      ),
                      label: Text(
                        'Prendre un RDV',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _showReviewsDialog(String username, String rating, String reviewCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Text(
                    'Avis clients',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "$rating/5",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        " ($reviewCount avis)",
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
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.r,
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 20.r,
                                color: Colors.grey[400],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Client ${index + 1}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => Icon(
                                        Icons.star,
                                        size: 14.w,
                                        color: i < 4 ? Colors.amber : Colors.grey[300],
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "il y a 2 jours",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
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
                          "Excellent service ! Je recommande vivement ce professionnel. Le travail est soigné et le résultat est à la hauteur de mes attentes.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
