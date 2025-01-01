import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import '../screens/service_booking_screen.dart';

class DynamicLinksService {
  static Future<void> initDynamicLinks(BuildContext context) async {
    // Gérer les liens dynamiques lorsque l'application est en arrière-plan
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData.link, context);
    }).onError((error) {
      print('Erreur de lien dynamique: $error');
    });

    // Gérer les liens dynamiques lorsque l'application est fermée
    final PendingDynamicLinkData? initialLink = 
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _handleDynamicLink(initialLink.link, context);
    }
  }

  static void _handleDynamicLink(Uri uri, BuildContext context) {
    // Extraire l'ID du service du lien
    final String? serviceId = uri.queryParameters['id'];
    if (serviceId != null) {
      // Naviguer vers l'écran de réservation avec l'ID du service
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceBookingScreen(serviceId: serviceId),
        ),
      );
    }
  }

  static Future<String> createServiceLink(String serviceId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://shayniss.page.link',
      link: Uri.parse('https://shayniss.app/service?id=$serviceId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.shayniss.app',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.shayniss.app',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Shayniss Beauty - Réservation',
        description: 'Réservez votre service beauté en quelques clics !',
        imageUrl: Uri.parse('https://shayniss.app/assets/images/logo.png'),
      ),
    );

    final ShortDynamicLink shortLink = 
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }
}
