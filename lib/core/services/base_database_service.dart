import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseDatabaseService<T> {
  final String _tableName;
  final SupabaseClient _client = Supabase.instance.client;

  BaseDatabaseService(this._tableName);

  SupabaseClient get client => _client;
  String get tableName => _tableName;

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T item);
}
