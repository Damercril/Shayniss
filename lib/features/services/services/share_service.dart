import 'package:uuid/uuid.dart';

class ShareService {
  static final Map<String, String> _shortLinks = {};
  static const String _baseUrl = 'shayniss-booking.netlify.app';

  static String createShareableLink({
    required String serviceName,
    required String price,
    required String duration,
  }) {
    // Créer l'URL avec les paramètres du service
    final String serviceUrl = 'https://$_baseUrl?' + Uri(queryParameters: {
      'service': serviceName,
      'price': price,
      'duration': duration,
    }).query;
    
    return serviceUrl;
  }

  // Cette méthode serait utilisée quand on implémentera la redirection
  static String? getServiceFromShortId(String shortId) {
    return _shortLinks[shortId];
  }
}
