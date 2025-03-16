import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/category_service.dart';
import '../widgets/service_photos_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/share_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final CategoryService _categoryService = CategoryService();

  Future<List<String>> _loadServiceImages() async {
    return await _categoryService.getRandomServiceImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<String>>(
        future: _loadServiceImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final serviceImages = snapshot.data ?? [];

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildCategorySection(context, 'Coiffure', [
                _buildServiceCard(
                  context,
                  'Coupe Femme',
                  '1h30',
                  '45€',
                  Icons.content_cut,
                  serviceImages,
                ),
                _buildServiceCard(
                  context,
                  'Coloration',
                  '2h00',
                  '65€',
                  Icons.palette,
                  serviceImages,
                ),
                _buildServiceCard(
                  context,
                  'Brushing',
                  '45min',
                  '30€',
                  Icons.brush,
                  serviceImages,
                ),
              ]),
              SizedBox(height: 24.h),
              _buildCategorySection(context, 'Manucure', [
                _buildServiceCard(
                  context,
                  'Manucure Simple',
                  '45min',
                  '25€',
                  Icons.spa,
                  serviceImages,
                ),
                _buildServiceCard(
                  context,
                  'Pose Gel',
                  '1h15',
                  '45€',
                  Icons.diamond,
                  serviceImages,
                ),
              ]),
              SizedBox(height: 24.h),
              _buildCategorySection(context, 'Maquillage', [
                _buildServiceCard(
                  context,
                  'Maquillage Jour',
                  '45min',
                  '35€',
                  Icons.face,
                  serviceImages,
                ),
                _buildServiceCard(
                  context,
                  'Maquillage Soirée',
                  '1h00',
                  '50€',
                  Icons.face_retouching_natural,
                  serviceImages,
                ),
              ]),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceModal(context),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: Text(
        'Services',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppColors.text),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<Widget> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 16.h),
        ...services,
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String name,
    String duration,
    String price,
    IconData icon,
    List<String> serviceImages,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Column(
        children: [
          // Galerie de photos
          ServicePhotosGallery(
            photoUrls: serviceImages,
            mainPhotoUrl: serviceImages.isNotEmpty ? serviceImages[0] : null,
            isEditable: true,
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Populaire',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text('Modifier'),
                          value: 'edit',
                        ),
                        PopupMenuItem(
                          child: Text('Supprimer'),
                          value: 'delete',
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditServiceModal(context);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.w,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
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
                      price,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showShareOptions(context, name, price, duration),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(
                          FontAwesomeIcons.shareNodes,
                          color: Colors.white,
                          size: 16.w,
                        ),
                        label: Text(
                          'Partager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            _buildModalHeader(context, 'Nouveau service'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModalField('Nom du service', Icons.spa_outlined),
                    _buildModalField('Catégorie', Icons.category_outlined),
                    _buildModalField('Durée', Icons.access_time_outlined),
                    _buildModalField('Prix', Icons.euro_outlined),
                    _buildModalField('Description', Icons.description_outlined),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textLight.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModalField(String label, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.textLight.withOpacity(0.2),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditServiceModal(BuildContext context) {
    _showAddServiceModal(context); // Réutilise le même modal avec des données pré-remplies
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le service'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce service ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Non',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // Logique de suppression
              Navigator.pop(context);
            },
            child: Text(
              'Oui',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer par',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFilterOption('Tous les services'),
            _buildFilterOption('Coiffure'),
            _buildFilterOption('Manucure'),
            _buildFilterOption('Maquillage'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, String serviceName, String price, String duration) {
    // Générer un lien court pour ce service
    final String serviceLink = ShareService.createShareableLink(
      serviceName: serviceName,
      price: price,
      duration: duration,
    );

    final messageText = '''✨ $serviceName chez Shayniss Beauty

⏰ Durée : $duration
💰 Prix : $price

💅 Réservez facilement en ligne :
$serviceLink

À bientôt dans notre salon ! 💖''';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalHeader(context, 'Partager le service'),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  'Partager',
                  FontAwesomeIcons.shareNodes,
                  AppColors.primary,
                  () => _shareService(context, messageText),
                ),
                _buildShareButton(
                  'Copier',
                  Icons.copy,
                  Colors.grey,
                  () => _copyToClipboard(context, messageText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareService(BuildContext context, String message) async {
    Navigator.pop(context);
    await Share.share(
      message,
      subject: 'Réservez votre service beauté',
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lien copié dans le presse-papiers !'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

class ServicePhotosGallery extends StatefulWidget {
  final List<String> photoUrls;
  final String? mainPhotoUrl;
  final bool isEditable;

  const ServicePhotosGallery({
    Key? key,
    required this.photoUrls,
    this.mainPhotoUrl,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<ServicePhotosGallery> createState() => _ServicePhotosGalleryState();
}

class _ServicePhotosGalleryState extends State<ServicePhotosGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.mainPhotoUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.photoUrls.asMap().entries.map((entry) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
