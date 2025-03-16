import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_type.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _themeKey = 'theme_mode';
  static const String _phoneKey = 'phone_number';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Connecte l'utilisateur avec son numéro de téléphone et son code PIN
  static Future<bool> login({
    required String phoneNumber,
    required String pin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // TODO: Implémenter la vraie logique de connexion avec l'API
    // Pour le moment, on simule une vérification
    bool isValidCredentials = await _verifyCredentials(phoneNumber, pin);
    if (!isValidCredentials) return false;

    // Récupérer le type d'utilisateur depuis l'API
    UserType? userType = await _getUserTypeFromAPI(phoneNumber);
    if (userType == null) return false;
    
    // Stocker les informations de l'utilisateur
    await prefs.setString(_tokenKey, 'token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString(_userIdKey, 'user_$phoneNumber');
    await prefs.setString(_userTypeKey, userType.toJson());
    await prefs.setString(_phoneKey, phoneNumber);

    return true;
  }

  /// Vérifie les identifiants (simulation)
  static Future<bool> _verifyCredentials(String phoneNumber, String pin) async {
    // TODO: Implémenter la vraie vérification avec l'API
    // Pour le moment, on accepte tout numéro de téléphone valide et PIN à 4 chiffres
    bool isValidPhone = phoneNumber.length == 10 && phoneNumber.startsWith('0');
    bool isValidPin = pin.length == 4 && int.tryParse(pin) != null;
    
    return isValidPhone && isValidPin;
  }

  /// Récupère le type d'utilisateur depuis l'API (simulation)
  static Future<UserType?> _getUserTypeFromAPI(String phoneNumber) async {
    // TODO: Implémenter la vraie récupération depuis l'API
    // Pour le moment, on simule : si le numéro commence par "06", c'est un pro
    if (phoneNumber.startsWith('06')) {
      return UserType.professional;
    } else if (phoneNumber.startsWith('07')) {
      return UserType.client;
    }
    return null;
  }

  /// Déconnecte l'utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder le thème actuel
    final currentTheme = prefs.getString(_themeKey);
    
    // Effacer toutes les données sauf le thème
    await prefs.clear();
    
    // Restaurer le thème
    if (currentTheme != null) {
      await prefs.setString(_themeKey, currentTheme);
    }
  }

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  /// Récupère le numéro de téléphone de l'utilisateur connecté
  static Future<String?> getCurrentPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Récupère le type d'utilisateur actuel
  static Future<UserType?> getCurrentUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userTypeStr = prefs.getString(_userTypeKey);
    if (userTypeStr == null) return null;
    
    try {
      return UserType.fromString(userTypeStr);
    } catch (e) {
      print('Erreur lors de la récupération du type d\'utilisateur: $e');
      return null;
    }
  }

  /// Vérifie si l'utilisateur est un professionnel
  static Future<bool> isProfessional() async {
    final userType = await getCurrentUserType();
    return userType == UserType.professional;
  }

  /// Vérifie si l'utilisateur est un client
  static Future<bool> isClient() async {
    final userType = await getCurrentUserType();
    return userType == UserType.client;
  }

  Future<String?> getCurrentUserId() async {
    return _client.auth.currentUser?.id;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.shayniss://reset-callback/',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(
        password: newPassword,
      ),
    );
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  bool get isAuthenticated => _client.auth.currentUser != null;
}
