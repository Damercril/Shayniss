import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';
import '../exceptions/service_validation_exception.dart';
import '../exceptions/service_database_exception.dart';

class ServiceDatabaseService {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'services';

  Future<List<ServiceModel>> getServicesByProfessionalId(String professionalId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('professional_id', professionalId)
          .eq('is_active', true)
          .order('name');

      return List<ServiceModel>.from(
        response.map((json) => ServiceModel.fromJson(json)),
      );
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la récupération des services',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la récupération des services',
        e,
      );
    }
  }

  Future<ServiceModel> getServiceById(String serviceId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('id', serviceId)
          .single();

      return ServiceModel.fromJson(response);
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la récupération du service',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la récupération du service',
        e,
      );
    }
  }

  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('name');

      return List<ServiceModel>.from(
        response.map((json) => ServiceModel.fromJson(json)),
      );
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la récupération des services par catégorie',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la récupération des services par catégorie',
        e,
      );
    }
  }

  Future<List<ServiceModel>> searchServices({
    String? query,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    String? category,
    String? professionalId,
  }) async {
    try {
      var request = client
          .from(tableName)
          .select()
          .eq('is_active', true);

      if (query != null && query.isNotEmpty) {
        request = request.textSearch(
          'name,description,category',
          query,
          config: 'french',
        );
      }

      if (minPrice != null) {
        request = request.gte('price', minPrice);
      }

      if (maxPrice != null) {
        request = request.lte('price', maxPrice);
      }

      if (minDuration != null) {
        request = request.gte('duration_minutes', minDuration);
      }

      if (maxDuration != null) {
        request = request.lte('duration_minutes', maxDuration);
      }

      if (category != null) {
        request = request.eq('category', category);
      }

      if (professionalId != null) {
        request = request.eq('professional_id', professionalId);
      }

      final response = await request.order('name');

      return List<ServiceModel>.from(
        response.map((json) => ServiceModel.fromJson(json)),
      );
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la recherche des services',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la recherche des services',
        e,
      );
    }
  }

  Future<List<ServiceModel>> getPopularServices() async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('is_active', true)
          .order('booking_count', ascending: false)
          .limit(10);

      return List<ServiceModel>.from(
        response.map((json) => ServiceModel.fromJson(json)),
      );
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la récupération des services populaires',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la récupération des services populaires',
        e,
      );
    }
  }

  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      final response = await client
          .from(tableName)
          .insert(service.toJson())
          .select()
          .single();

      return ServiceModel.fromJson(response);
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la création du service',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la création du service',
        e,
      );
    }
  }

  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      final response = await client
          .from(tableName)
          .update(service.toJson())
          .eq('id', service.id)
          .select()
          .single();

      return ServiceModel.fromJson(response);
    } on ServiceValidationException catch (e) {
      throw ServiceDatabaseException(
        'Erreur de validation lors de la mise à jour du service',
        e,
      );
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la mise à jour du service',
        e,
      );
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await client
          .from(tableName)
          .delete()
          .eq('id', serviceId);
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de la suppression du service',
        e,
      );
    }
  }

  Future<void> incrementBookingCount(String serviceId) async {
    try {
      await client
          .rpc('increment_service_booking_count', params: {'service_id': serviceId});
    } catch (e) {
      throw ServiceDatabaseException(
        'Erreur lors de l\'incrémentation du nombre de réservations',
        e,
      );
    }
  }
}
