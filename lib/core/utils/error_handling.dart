/// Exception pour les erreurs de validation des services
class ServiceValidationException implements Exception {
  final String message;
  final dynamic originalError;

  ServiceValidationException(this.message, {this.originalError});

  @override
  String toString() => message;
}

/// Exception pour les erreurs de base de données des services
class ServiceDatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  ServiceDatabaseException(this.message, {this.originalError});

  @override
  String toString() => message;
}

/// Classe utilitaire pour gérer les erreurs
class ErrorHandler {
  /// Convertit une exception en message d'erreur utilisateur
  static String getErrorMessage(dynamic error) {
    if (error is ServiceValidationException) {
      return error.message;
    } else if (error is ServiceDatabaseException) {
      return error.message;
    } else {
      return 'Une erreur est survenue: $error';
    }
  }

  /// Détermine si une erreur est une erreur de validation
  static bool isValidationError(dynamic error) {
    return error is ServiceValidationException;
  }

  /// Détermine si une erreur est une erreur de base de données
  static bool isDatabaseError(dynamic error) {
    return error is ServiceDatabaseException;
  }
}
