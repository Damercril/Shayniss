class ServiceDatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  ServiceDatabaseException(this.message, [this.originalError]);

  @override
  String toString() => originalError != null 
      ? '$message (${originalError.toString()})'
      : message;
}
