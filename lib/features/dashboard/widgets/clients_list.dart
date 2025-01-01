import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../clients/screens/client_details_screen.dart';

class ClientsList extends StatelessWidget {
  const ClientsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          // En-tête avec recherche
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un client...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20.w,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Ajouter un nouveau client
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des clients
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              // Données de test réalistes
              final clients = [
                {
                  'name': 'Emma Laurent',
                  'initials': 'EL',
                  'lastVisit': '28 Déc. 2024',
                  'visits': '3 visites',
                },
                {
                  'name': 'Sophie Martin',
                  'initials': 'SM',
                  'lastVisit': '23 Déc. 2024',
                  'visits': '12 visites',
                },
                {
                  'name': 'Marie Dubois',
                  'initials': 'MD',
                  'lastVisit': '20 Déc. 2024',
                  'visits': '8 visites',
                },
                {
                  'name': 'Julie Bernard',
                  'initials': 'JB',
                  'lastVisit': '18 Déc. 2024',
                  'visits': '5 visites',
                },
                {
                  'name': 'Léa Petit',
                  'initials': 'LP',
                  'lastVisit': '15 Déc. 2024',
                  'visits': '15 visites',
                },
                {
                  'name': 'Chloé Moreau',
                  'initials': 'CM',
                  'lastVisit': '12 Déc. 2024',
                  'visits': '6 visites',
                },
                {
                  'name': 'Alice Roux',
                  'initials': 'AR',
                  'lastVisit': '10 Déc. 2024',
                  'visits': '4 visites',
                },
                {
                  'name': 'Camille Simon',
                  'initials': 'CS',
                  'lastVisit': '8 Déc. 2024',
                  'visits': '9 visites',
                },
                {
                  'name': 'Inès Girard',
                  'initials': 'IG',
                  'lastVisit': '5 Déc. 2024',
                  'visits': '7 visites',
                },
                {
                  'name': 'Manon Lambert',
                  'initials': 'ML',
                  'lastVisit': '3 Déc. 2024',
                  'visits': '10 visites',
                },
              ];

              final client = clients[index];
              final visitCount = int.parse(client['visits']!.split(' ')[0]);
              
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailsScreen(
                        clientId: 'client_$index', // TODO: Utiliser un vrai ID
                        clientName: client['name']!,
                      ),
                    ),
                  );
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                leading: CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    client['initials']!,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                title: Text(
                  client['name']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                subtitle: Text(
                  'Dernier RDV: ${client['lastVisit']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getVisitColor(visitCount).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    client['visits']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _getVisitColor(visitCount),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getVisitColor(int visits) {
    if (visits >= 10) return Colors.purple; // Client fidèle
    if (visits >= 5) return Colors.green; // Client régulier
    return Colors.blue; // Nouveau client
  }
}
