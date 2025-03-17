class ServiceValidationException implements Exception {
  final String message;
  ServiceValidationException(this.message);
  @override
  String toString() => message;
}
