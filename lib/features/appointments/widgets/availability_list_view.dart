import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/availability.dart';
import '../services/availability_service.dart';
import 'availability_form_dialog.dart';

class AvailabilityListView extends StatelessWidget {
  final List<Availability> availabilities;
  final VoidCallback onAvailabilityDeleted;
  final VoidCallback onAvailabilityUpdated;

  const AvailabilityListView({
    Key? key,
    required this.availabilities,
    required this.onAvailabilityDeleted,
    required this.onAvailabilityUpdated,
  }) : super(key: key);

  Future<void> _showEditDialog(BuildContext context, Availability availability) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AvailabilityFormDialog(
        initialDate: availability.startTime,
        availability: availability,
      ),
    );

    if (result == true) {
      onAvailabilityUpdated();
    }
  }

  Future<void> _deleteAvailability(BuildContext context, Availability availability) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la disponibilité'),
        content: Text(
          availability.isRecurring
              ? 'Voulez-vous supprimer cette disponibilité récurrente ?'
              : 'Voulez-vous supprimer cette disponibilité ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AvailabilityService.instance.deleteAvailability(availability.id);
        onAvailabilityDeleted();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (availabilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48.w,
              color: Colors.grey,
            ),
            SizedBox(height: 8.h),
            const Text(
              'Aucune disponibilité pour ce jour',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.w),
      itemCount: availabilities.length,
      itemBuilder: (context, index) {
        final availability = availabilities[index];
        return Card(
          child: ListTile(
            title: Text(
              '${TimeOfDay.fromDateTime(availability.startTime).format(context)} - '
              '${TimeOfDay.fromDateTime(availability.endTime).format(context)}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (availability.isRecurring)
                  const Text(
                    'Récurrent',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                if (availability.notes?.isNotEmpty == true)
                  Text(
                    availability.notes!,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, availability),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAvailability(context, availability),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
