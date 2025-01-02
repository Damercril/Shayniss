enum UserType {
  professional,
  client;

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'professional':
        return UserType.professional;
      case 'client':
        return UserType.client;
      default:
        throw ArgumentError('Invalid user type: $value');
    }
  }

  String toJson() => name;
}
