import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/referral.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/base_database_service.dart';
import 'package:shayniss/core/utils/error_handling.dart';

class AffiliationService extends BaseDatabaseService<Referral> {
  static final AffiliationService _instance = AffiliationService._internal();
  final SupabaseClient _supabase = SupabaseService.client;
  
  // Taux de commission par défaut (5%)
  static const double DEFAULT_COMMISSION_RATE = 0.05;
  
  factory AffiliationService() {
    return _instance;
  }
  
  AffiliationService._internal() : super('referrals');
  
  @override
  Referral fromJson(Map<String, dynamic> json) => Referral.fromJson(json);
  
  @override
  Map<String, dynamic> toJson(Referral item) => item.toJson();
  
  /// Génère un code de parrainage unique pour un client
  Future<String> generateReferralCode(String clientId) async {
    try {
      final response = await _supabase.rpc(
        'generate_referral_code',
        params: {'client_id': clientId},
      );
      
      return response as String;
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la génération du code de parrainage: $e',
        originalError: e,
      );
    }
  }
  
  /// Récupère le code de parrainage d'un client
  Future<String?> getClientReferralCode(String clientId) async {
    try {
      final response = await _supabase
          .from('client_referral_codes')
          .select('code')
          .eq('client_id', clientId)
          .single();
      
      return response['code'] as String?;
    } catch (e) {
      // Si aucun code n'existe, on en génère un nouveau
      if (e is PostgrestException && e.code == 'PGRST116') {
        final newCode = await generateReferralCode(clientId);
        await _supabase.from('client_referral_codes').insert({
          'client_id': clientId,
          'code': newCode,
        });
        return newCode;
      }
      
      throw ServiceDatabaseException(
        'Erreur lors de la récupération du code de parrainage: $e',
        originalError: e,
      );
    }
  }
  
  /// Enregistre un parrainage lorsqu'un nouveau client s'inscrit avec un code
  Future<void> registerReferral(String referrerClientId, String newClientId) async {
    try {
      await _supabase.from('client_referrals').insert({
        'referrer_id': referrerClientId,
        'referred_id': newClientId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de l\'enregistrement du parrainage: $e',
        originalError: e,
      );
    }
  }
  
  /// Calcule et enregistre une commission lorsqu'un client parrainé effectue une réservation
  Future<void> processCommission(String bookingId, double amount) async {
    try {
      await _supabase.rpc(
        'process_referral_commission',
        params: {
          'booking_id': bookingId,
          'amount': amount,
          'commission_rate': DEFAULT_COMMISSION_RATE,
        },
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors du traitement de la commission: $e',
        originalError: e,
      );
    }
  }
  
  /// Récupère toutes les commissions d'un client
  Future<List<Referral>> getClientCommissions(String clientId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false);
      
      return response.map<Referral>((json) => fromJson(json)).toList();
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la récupération des commissions: $e',
        originalError: e,
      );
    }
  }
  
  /// Récupère le total des commissions gagnées par un client
  Future<Map<String, dynamic>> getClientCommissionStats(String clientId) async {
    try {
      final response = await _supabase.rpc(
        'get_client_commission_stats',
        params: {'client_id_param': clientId},
      );
      
      return {
        'totalEarned': (response['total_earned'] as num?)?.toDouble() ?? 0.0,
        'totalPaid': (response['total_paid'] as num?)?.toDouble() ?? 0.0,
        'pendingAmount': (response['pending_amount'] as num?)?.toDouble() ?? 0.0,
        'referralCount': response['referral_count'] as int? ?? 0,
      };
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la récupération des statistiques de commission: $e',
        originalError: e,
      );
    }
  }
}
