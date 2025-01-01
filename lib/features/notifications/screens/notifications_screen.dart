import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppNotification> _notifications;
  NotificationType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notifications = AppNotification.samples;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedType == null) {
      return _notifications;
    }
    return _notifications
        .where((notification) => notification.type == _selectedType)
        .toList();
  }

  List<AppNotification> get _unreadNotifications {
    return _filteredNotifications.where((notification) => !notification.isRead).toList();
  }

  List<AppNotification> get _readNotifications {
    return _filteredNotifications.where((notification) => notification.isRead).toList();
  }

  void _markAsRead(AppNotification notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    });
  }

  void _deleteNotification(AppNotification notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          if (_filteredNotifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              color: AppColors.text,
              onPressed: _markAllAsRead,
              tooltip: 'Tout marquer comme lu',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: Column(
            children: [
              // Filtres par type
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Tout'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedType == null
                            ? AppColors.primary
                            : AppColors.text,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ...NotificationType.values.map((type) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(type.label),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                          backgroundColor: type.color.withOpacity(0.1),
                          selectedColor: type.color.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedType == type
                                ? type.color
                                : AppColors.text,
                            fontSize: 12.sp,
                          ),
                          avatar: Icon(
                            type.icon,
                            size: 16.w,
                            color:
                                _selectedType == type ? type.color : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Tabs Non lu / Lu
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Non lu'),
                        if (_unreadNotifications.isNotEmpty) ...[
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              _unreadNotifications.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Lu'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Non lu
          _buildNotificationsList(_unreadNotifications),
          // Onglet Lu
          _buildNotificationsList(_readNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 48.w,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          background: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => _deleteNotification(notification),
          child: Card(
            margin: EdgeInsets.only(bottom: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () => _markAsRead(notification),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          notification.type.icon,
                          size: 20.w,
                          color: notification.type.color,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          notification.type.label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: notification.type.color,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notification.date.timeAgo,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    if (notification.data != null &&
                        notification.type == NotificationType.appointment)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                // TODO: Naviguer vers le rendez-vous
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: const Text('Voir le rendez-vous'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
