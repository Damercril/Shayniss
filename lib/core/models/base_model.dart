/// Classe de base pour tous les modèles de données
abstract class BaseModel {
  /// Convertit le modèle en Map pour la sérialisation JSON
  Map<String, dynamic> toJson();
  
  /// Date de création
  DateTime get createdAt;
  
  /// Date de mise à jour
  DateTime get updatedAt;
}
