import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../professional/models/professional.dart';
import '../../professional/controllers/professional_controller.dart';

class ProfessionalFilter extends StatefulWidget {
  final String? selectedProfessionalId;
  final Function(String?) onProfessionalSelected;
  final bool showAllOption;

  const ProfessionalFilter({
    Key? key,
    this.selectedProfessionalId,
    required this.onProfessionalSelected,
    this.showAllOption = true,
  }) : super(key: key);

  @override
  State<ProfessionalFilter> createState() => _ProfessionalFilterState();
}

class _ProfessionalFilterState extends State<ProfessionalFilter> {
  final ProfessionalController _controller = ProfessionalController();
  List<Professional> _professionals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    setState(() => _isLoading = true);
    try {
      final professionals = await _controller.getProfessionals();
      setState(() => _professionals = professionals);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des professionnels: $e')),
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
            'Filtrer par professionnel',
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
                      label: const Text('Tous'),
                      selected: widget.selectedProfessionalId == null,
                      onSelected: (selected) {
                        if (selected) {
                          widget.onProfessionalSelected(null);
                        }
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
                ..._professionals.map((professional) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: FilterChip(
                    avatar: professional.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(professional.photoUrl!),
                            radius: 12.r,
                          )
                        : CircleAvatar(
                            child: Text(
                              professional.name[0].toUpperCase(),
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            radius: 12.r,
                          ),
                    label: Text(professional.name),
                    selected: widget.selectedProfessionalId == professional.id,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onProfessionalSelected(professional.id);
                      } else if (widget.showAllOption) {
                        widget.onProfessionalSelected(null);
                      }
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }
}
