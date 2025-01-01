import 'package:flutter/material.dart';
import '../models/professional_model.dart';

class ProfessionalController extends ChangeNotifier {
  List<Professional> _professionals = [];

  List<Professional> get professionals => _professionals;

  Future<void> fetchProfessionals() async {
    // TODO: Implémenter la récupération des professionnels depuis une API
    _professionals = [
      Professional(
        id: '1',
        name: 'John Doe',
        specialty: 'Coiffeur',
        rating: 4.5,
        reviews: 120,
      ),
      Professional(
        id: '2',
        name: 'Jane Smith',
        specialty: 'Esthéticienne',
        rating: 4.8,
        reviews: 85,
      ),
    ];
    notifyListeners();
  }

  Future<void> addProfessional(Professional professional) async {
    // TODO: Implémenter l'ajout d'un professionnel via une API
    _professionals.add(professional);
    notifyListeners();
  }

  Future<void> updateProfessional(Professional professional) async {
    // TODO: Implémenter la mise à jour d'un professionnel via une API
    final index = _professionals.indexWhere((p) => p.id == professional.id);
    if (index != -1) {
      _professionals[index] = professional;
      notifyListeners();
    }
  }

  Future<void> deleteProfessional(String id) async {
    // TODO: Implémenter la suppression d'un professionnel via une API
    _professionals.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
