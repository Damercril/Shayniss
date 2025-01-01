class AppConstants {
  static const String appName = 'Shayniss';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.shayniss.com';
  static const String apiVersion = 'v1';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String professionalsCollection = 'professionals';
  static const String appointmentsCollection = 'appointments';
  static const String servicesCollection = 'services';
  static const String reviewsCollection = 'reviews';
  
  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String userTypeKey = 'userType';
  
  // App Routes
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String appointmentsRoute = '/appointments';
  static const String servicesRoute = '/services';
  static const String statisticsRoute = '/statistics';
  
  // Asset Paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Cache Duration
  static const int cacheDuration = 7; // 7 days
}
