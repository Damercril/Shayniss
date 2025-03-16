import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/service_category.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../appointments/widgets/add_appointment_modal.dart';
import '../../services/models/service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../messages/screens/messages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  List<ServiceCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoading = true);
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: CommonAppBar(
                      title: 'Shayniss',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildServicesSection(),
                        _buildUpcomingAppointments(),
                        _buildServicesFeed(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SizedBox(
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
          _buildAppointmentCard(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
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
                      'Aujourd\'hui, 14:30',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Coupe et Brushing avec Sarah',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24.w,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesFeed() {
    return Column(
      children: _categories.map((category) {
        return _buildServicePost(category);
      }).toList(),
    );
  }

  Widget _buildServicePost(ServiceCategory category) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(category),
          _buildPostImage(category),
          _buildPostActions(category),
          _buildPostCaption(category),
        ],
      ),
    );
  }

  Widget _buildPostHeader(ServiceCategory category) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(category.icon),
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
                  category.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(ServiceCategory category) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(category.icon),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPostActions(ServiceCategory category) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: AppColors.like),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddAppointmentModal(
                  service: Service(
                    id: '1', // TODO: Use actual service ID
                    name: category.name,
                    category: category.name.toLowerCase(),
                    description: category.description,
                    duration: 60, // TODO: Use actual duration
                    price: 50.0, // TODO: Use actual price
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20.w,
            ),
            label: Text(
              'Prendre RDV',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCaption(ServiceCategory category) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1,234 likes',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: category.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                TextSpan(
                  text: ' ${category.description}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.text,
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
