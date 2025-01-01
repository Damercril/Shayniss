import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../widgets/service_selection.dart';
import '../widgets/photo_upload_section.dart';

class AppointmentForm extends StatefulWidget {
  final DateTime selectedDateTime;

  const AppointmentForm({
    super.key,
    required this.selectedDateTime,
  });

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  List<Service> selectedServices = [];
  List<File> selectedPhotos = [];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nouveau rendez-vous',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateTimeSection(),
              SizedBox(height: 24.h),
              _buildClientInfoSection(),
              SizedBox(height: 24.h),
              ServiceSelection(
                onServicesSelected: (services) {
                  setState(() {
                    selectedServices = services;
                  });
                },
              ),
              SizedBox(height: 24.h),
              PhotoUploadSection(
                onPhotosSelected: (photos) {
                  setState(() {
                    selectedPhotos = photos;
                  });
                },
                initialPhotos: const [],
              ),
              SizedBox(height: 24.h),
              _buildNotesSection(),
              SizedBox(height: 32.h),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            color: AppColors.primary,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date et heure',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '${widget.selectedDateTime.day}/${widget.selectedDateTime.month}/${widget.selectedDateTime.year} à ${widget.selectedDateTime.hour}:${widget.selectedDateTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations client',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Téléphone',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un numéro de téléphone';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un email';
            }
            if (!value.contains('@')) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ajoutez des notes ou des instructions spéciales...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: selectedServices.isEmpty
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                // TODO: Sauvegarder le rendez-vous
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rendez-vous enregistré avec succès !'),
                  ),
                );
                Navigator.pop(context);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
      ),
      child: Text(
        'Confirmer le rendez-vous',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
