import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(context),
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

  Widget _buildBody(BuildContext context) {
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
          ),
          _buildServiceCard(
            context,
            'Coloration',
            '2h00',
            '65€',
            Icons.palette,
          ),
          _buildServiceCard(
            context,
            'Brushing',
            '45min',
            '30€',
            Icons.brush,
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
          ),
          _buildServiceCard(
            context,
            'Pose Gel',
            '1h15',
            '45€',
            Icons.diamond,
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
          ),
          _buildServiceCard(
            context,
            'Maquillage Soirée',
            '1h00',
            '50€',
            Icons.face_retouching_natural,
          ),
        ]),
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
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24.w,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        subtitle: Text(
          duration,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 16.w),
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
}
