import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shayniss/core/theme/app_colors.dart';
import 'package:shayniss/core/utils/date_formatter.dart';
import 'package:shayniss/core/widgets/error_widget.dart';
import 'package:shayniss/core/widgets/shimmer_loading.dart';
import 'package:shayniss/features/affiliation/models/referral.dart';
import 'package:shayniss/features/affiliation/services/affiliation_service.dart';
import 'package:shayniss/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientEarningsScreen extends StatefulWidget {
  const ClientEarningsScreen({Key? key}) : super(key: key);

  @override
  State<ClientEarningsScreen> createState() => _ClientEarningsScreenState();
}

class _ClientEarningsScreenState extends State<ClientEarningsScreen> with SingleTickerProviderStateMixin {
  final AffiliationService _affiliationService = AffiliationService();
  late TabController _tabController;
  
  bool _isLoading = true;
  String? _error;
  String? _referralCode;
  String? _referralLink;
  Map<String, dynamic> _stats = {};
  List<Referral> _commissions = [];
  List<Map<String, dynamic>> _referrals = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Utiliser des données fictives pour la démo
      await Future.delayed(const Duration(milliseconds: 800)); // Simuler un délai réseau
      
      if (mounted) {
        setState(() {
          // Code de parrainage fictif
          _referralCode = "SARAH2025";
          _referralLink = "https://shayniss.com/referral/SARAH2025";
          
          // Statistiques fictives
          _stats = {
            'totalEarned': 157.50,
            'totalPaid': 102.50,
            'pendingAmount': 55.00,
            'referralCount': 7,
            'usageCount': 12,
            'conversionRate': 58.3, // en pourcentage
            'averageBasket': 185.75,
          };
          
          // Commissions fictives
          _commissions = [
            Referral(
              id: '1',
              clientId: 'client123',
              professionalId: 'pro456',
              bookingId: 'booking789',
              amount: 120.00,
              commissionRate: 0.05,
              commissionAmount: 6.00,
              isPaid: true,
              paidAt: DateTime.now().subtract(const Duration(days: 2)),
              createdAt: DateTime.now().subtract(const Duration(days: 5)),
              updatedAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
            Referral(
              id: '2',
              clientId: 'client123',
              professionalId: 'pro789',
              bookingId: 'booking012',
              amount: 250.00,
              commissionRate: 0.05,
              commissionAmount: 12.50,
              isPaid: true,
              paidAt: DateTime.now().subtract(const Duration(days: 10)),
              createdAt: DateTime.now().subtract(const Duration(days: 12)),
              updatedAt: DateTime.now().subtract(const Duration(days: 10)),
            ),
            Referral(
              id: '3',
              clientId: 'client123',
              professionalId: 'pro456',
              bookingId: 'booking345',
              amount: 180.00,
              commissionRate: 0.05,
              commissionAmount: 9.00,
              isPaid: false,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              updatedAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
            Referral(
              id: '4',
              clientId: 'client123',
              professionalId: 'pro123',
              bookingId: 'booking678',
              amount: 350.00,
              commissionRate: 0.05,
              commissionAmount: 17.50,
              isPaid: true,
              paidAt: DateTime.now().subtract(const Duration(days: 15)),
              createdAt: DateTime.now().subtract(const Duration(days: 20)),
              updatedAt: DateTime.now().subtract(const Duration(days: 15)),
            ),
            Referral(
              id: '5',
              clientId: 'client123',
              professionalId: 'pro789',
              bookingId: 'booking901',
              amount: 220.00,
              commissionRate: 0.05,
              commissionAmount: 11.00,
              isPaid: false,
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
              updatedAt: DateTime.now().subtract(const Duration(days: 3)),
            ),
          ];
          
          // Informations sur les clientes parrainées
          _referrals = [
            {
              'id': '1',
              'name': 'Alice Dupont',
              'email': 'alice.dupont@example.com',
              'referralDate': DateTime.now().subtract(const Duration(days: 10)),
              'professionalName': 'Sarah Martin',
              'professionalId': 'pro456',
              'bookingCount': 3,
              'totalSpent': 350.00,
              'lastBookingDate': DateTime.now().subtract(const Duration(days: 2)),
            },
            {
              'id': '2',
              'name': 'Léa Martin',
              'email': 'lea.martin@example.com',
              'referralDate': DateTime.now().subtract(const Duration(days: 5)),
              'professionalName': 'Marie Dubois',
              'professionalId': 'pro789',
              'bookingCount': 1,
              'totalSpent': 120.00,
              'lastBookingDate': DateTime.now().subtract(const Duration(days: 5)),
            },
            {
              'id': '3',
              'name': 'Anaïs Lopez',
              'email': 'anais.lopez@example.com',
              'referralDate': DateTime.now().subtract(const Duration(days: 2)),
              'professionalName': 'Julie Bernard',
              'professionalId': 'pro123',
              'bookingCount': 2,
              'totalSpent': 280.00,
              'lastBookingDate': DateTime.now().subtract(const Duration(days: 1)),
            },
          ];
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Impossible de charger les données: $e";
          _isLoading = false;
        });
      }
    }
  }
  
  void _copyReferralCode() {
    if (_referralCode != null) {
      Clipboard.setData(ClipboardData(text: _referralCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code de parrainage copié'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
  
  void _shareReferralCode() {
    if (_referralCode != null) {
      final String shareText = 
        'Rejoignez Shayniss avec mon code de parrainage: $_referralCode et bénéficiez de 10% de réduction sur votre première réservation! 💅✨\n\n'
        'Shayniss est l\'application idéale pour trouver des professionnels de beauté à domicile.\n\n'
        'Téléchargez l\'application ici:\n'
        '📱 iOS: https://apps.apple.com/fr/app/shayniss/id1234567890\n'
        '📱 Android: https://play.google.com/store/apps/details?id=com.shayniss.app\n\n'
        'Ou utilisez ce lien direct: $_referralLink';
      
      Share.share(
        shareText,
        subject: 'Mon code de parrainage Shayniss - $_referralCode',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mes Gains',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Tableau de bord'),
            Tab(text: 'Historique'),
            Tab(text: 'Parrainages'),
          ],
        ),
      ),
      body: _isLoading
          ? ShimmerLoading(
              child: _buildLoadingContent(),
            )
          : _error != null
              ? AppErrorWidget(
                  error: _error!,
                  onRetry: _loadData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboardTab(),
                    _buildHistoryTab(),
                    _buildNewTab(),
                  ],
                ),
    );
  }
  
  Widget _buildLoadingContent() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Carte de statistiques
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total des gains',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${_stats['referralCount']} parrainages',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  '${_stats['totalEarned'].toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildStatItem(
                        'Payé',
                        '${_stats['totalPaid'].toStringAsFixed(2)} €',
                        Icons.check_circle_outline,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildStatItem(
                        'En attente',
                        '${_stats['pendingAmount'].toStringAsFixed(2)} €',
                        Icons.pending_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Statistiques d'utilisation
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                Text(
                  'Statistiques d\'utilisation',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildUsageStatItem(
                        'Utilisations',
                        '${_stats['usageCount']}',
                        Icons.repeat,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildUsageStatItem(
                        'Conversion',
                        '${_stats['conversionRate']}%',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildUsageStatItem(
                        'Panier',
                        '${_stats['averageBasket'].toStringAsFixed(0)}€',
                        Icons.shopping_cart,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Carte de code de parrainage
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                Text(
                  'Mon code de parrainage',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _referralCode ?? 'Chargement...',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: AppColors.primary,
                            ),
                            onPressed: _copyReferralCode,
                            tooltip: 'Copier',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(8.w),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: AppColors.primary,
                            ),
                            onPressed: _shareReferralCode,
                            tooltip: 'Partager',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(8.w),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Mon lien de parrainage',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _referralLink ?? 'Chargement...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              if (_referralLink != null) {
                                Clipboard.setData(ClipboardData(text: _referralLink!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lien de parrainage copié'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            },
                            tooltip: 'Copier',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(8.w),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: AppColors.primary,
                            ),
                            onPressed: _shareReferralCode,
                            tooltip: 'Partager',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(8.w),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Comment ça marche
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                Text(
                  'Comment ça marche',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildStepItem(
                  '1',
                  'Partagez votre code',
                  'Invitez vos amis à rejoindre Shayniss avec votre code',
                ),
                SizedBox(height: 12.h),
                _buildStepItem(
                  '2',
                  'Ils réservent un service',
                  'Lorsqu\'ils effectuent une réservation',
                ),
                SizedBox(height: 12.h),
                _buildStepItem(
                  '3',
                  'Vous gagnez 5%',
                  'Recevez 5% du montant de chaque réservation',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    if (_commissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64.w,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucune commission pour le moment',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Partagez votre code pour commencer à gagner',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _shareReferralCode,
              icon: const Icon(Icons.share),
              label: const Text('Partager mon code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _commissions.length,
      itemBuilder: (context, index) {
        final commission = _commissions[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: commission.isPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                commission.isPaid
                    ? Icons.check_circle_outline
                    : Icons.pending_outlined,
                color: commission.isPaid ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              'Commission de ${commission.commissionAmount.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Réservation de ${commission.amount.toStringAsFixed(2)} €\n${DateFormatter.formatDateTime(commission.createdAt)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: commission.isPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                commission.isPaid ? 'Payé' : 'En attente',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: commission.isPaid ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
  
  Widget _buildNewTab() {
    if (_referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.w,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucun parrainage pour le moment',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Partagez votre code pour inviter vos amis',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _shareReferralCode,
              icon: const Icon(Icons.share),
              label: const Text('Partager mon code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _referrals.length,
      itemBuilder: (context, index) {
        final referral = _referrals[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            childrenPadding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 16.h),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                referral['name'].toString().substring(0, 1),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              referral['name'],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Parrainé(e) le ${DateFormatter.formatDate(referral['referralDate'])}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${referral['totalSpent'].toStringAsFixed(0)} €',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${referral['bookingCount']} rés.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_outlined, color: Colors.grey),
                title: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  referral['email'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: Text(
                  'Prestataire visité',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  referral['professionalName'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                title: Text(
                  'Dernière réservation',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  DateFormatter.formatDate(referral['lastBookingDate']),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Envoyer un message à la cliente
                      },
                      icon: const Icon(Icons.message_outlined, size: 16),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Voir le profil de la cliente
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.w,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildUsageStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.w,
              color: color,
            ),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
