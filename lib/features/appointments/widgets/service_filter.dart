import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../services/models/service.dart';
import '../../services/controllers/service_controller.dart';

class ServiceFilter extends StatefulWidget {
  final String? selectedServiceId;
  final Function(String?) onServiceSelected;
  final bool showAllOption;
  final String? professionalId;

  const ServiceFilter({
    Key? key,
    this.selectedServiceId,
    required this.onServiceSelected,
    this.showAllOption = true,
    this.professionalId,
  }) : super(key: key);

  @override
  State<ServiceFilter> createState() => _ServiceFilterState();
}

class _ServiceFilterState extends State<ServiceFilter> {
  final ServiceController _controller = ServiceController();
  List<Service> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void didUpdateWidget(ServiceFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.professionalId != oldWidget.professionalId) {
      _loadServices();
    }
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = widget.professionalId != null
          ? await _controller.getServicesByProfessional(widget.professionalId!)
          : await _controller.getAllServices();
      setState(() => _services = services);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des services: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'Filtrer par service',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: [
                if (widget.showAllOption)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: FilterChip(
                      label: const Text('Tous les services'),
                      selected: widget.selectedServiceId == null,
                      onSelected: (selected) {
                        if (selected) {
                          widget.onServiceSelected(null);
                        }
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
                ..._services.map((service) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: FilterChip(
                    avatar: CircleAvatar(
                      backgroundColor: Color(int.parse(service.color)),
                      radius: 12.r,
                      child: Icon(
                        IconData(service.iconData, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                        size: 16.r,
                      ),
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name),
                        Text(
                          '${service.duration} min - ${service.price.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    selected: widget.selectedServiceId == service.id,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onServiceSelected(service.id);
                      } else if (widget.showAllOption) {
                        widget.onServiceSelected(null);
                      }
                    },
                    selectedColor: Color(int.parse(service.color)).withOpacity(0.2),
                    checkmarkColor: Color(int.parse(service.color)),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }
}
