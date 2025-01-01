import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/payment_model.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late List<Payment> payments;
  late List<Payment> filteredPayments;
  String _selectedPeriod = 'Tout';
  PaymentStatus? _selectedStatus;
  
  final List<String> _periods = [
    'Tout',
    '7 jours',
    '30 jours',
    '3 mois',
    '6 mois',
    '1 an',
    'Personnalisé',
  ];

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    payments = Payment.samplePayments;
    filteredPayments = payments;
  }

  void _filterPayments() {
    setState(() {
      filteredPayments = payments.where((payment) {
        // Filtre par période
        bool matchesPeriod = true;
        final now = DateTime.now();
        
        switch (_selectedPeriod) {
          case '7 jours':
            matchesPeriod = payment.date.isAfter(
              now.subtract(const Duration(days: 7)),
            );
            break;
          case '30 jours':
            matchesPeriod = payment.date.isAfter(
              now.subtract(const Duration(days: 30)),
            );
            break;
          case '3 mois':
            matchesPeriod = payment.date.isAfter(
              now.subtract(const Duration(days: 90)),
            );
            break;
          case '6 mois':
            matchesPeriod = payment.date.isAfter(
              now.subtract(const Duration(days: 180)),
            );
            break;
          case '1 an':
            matchesPeriod = payment.date.isAfter(
              now.subtract(const Duration(days: 365)),
            );
            break;
          case 'Personnalisé':
            if (_startDate != null && _endDate != null) {
              matchesPeriod = payment.date.isAfter(_startDate!) &&
                  payment.date.isBefore(_endDate!.add(const Duration(days: 1)));
            }
            break;
          default:
            matchesPeriod = true;
        }

        // Filtre par statut
        bool matchesStatus = _selectedStatus == null || 
            payment.status == _selectedStatus;

        return matchesPeriod && matchesStatus;
      }).toList();

      // Tri par date (plus récent en premier)
      filteredPayments.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Personnalisé';
        _filterPayments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = filteredPayments.fold(
      0,
      (sum, payment) => sum + payment.amount,
    );

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
          'Historique des paiements',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: Column(
        children: [
          // Résumé des paiements
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total des revenus',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${totalAmount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedPeriod == 'Personnalisé' &&
                        _startDate != null &&
                        _endDate != null)
                      Text(
                        '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}\nau ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.right,
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          items: _periods
                              .map((period) => DropdownMenuItem(
                                    value: period,
                                    child: Text(period),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                              if (value == 'Personnalisé') {
                                _showDateRangePicker();
                              } else {
                                _filterPayments();
                              }
                            });
                          },
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtres rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: PaymentStatus.values.map((status) {
                bool isSelected = _selectedStatus == status;
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(status.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                        _filterPayments();
                      });
                    },
                    backgroundColor: status.color.withOpacity(0.1),
                    selectedColor: status.color.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: status.color,
                      fontSize: 12.sp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8.h),

          // Liste des paiements
          Expanded(
            child: filteredPayments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48.w,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Aucun paiement trouvé',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.w),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  payment.clientName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              Text(
                                '${payment.amount.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              Text(
                                payment.serviceName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        payment.method.icon,
                                        size: 16.w,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        payment.method.label,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: payment.status.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      payment.status.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: payment.status.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                payment.date.formattedDate,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Afficher les détails du paiement
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
