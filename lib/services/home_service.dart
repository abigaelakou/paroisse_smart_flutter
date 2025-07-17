// services/home_service.dart
import 'package:dio/dio.dart';
import '../models/pain_du_jour.dart';
import '../models/annonce.dart';
import '../models/evenement.dart';

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

Future<PainDuJour?> fetchPainDuJour() async {
  try {
    final response = await _dio.get('/pain-du-jour');
    if (response.statusCode == 200 &&
        response.data['status'] == true &&
        response.data['pain'] != null) {
      final pain = PainDuJour.fromJson(response.data['pain']);
      print("🎯 Pain reçu : ${pain.titre} | ${pain.contenu}");
      return pain;
    }
  } catch (e) {
    print("Erreur pain du jour : $e");
  }
  return null;
}


  Future<List<Annonce>> fetchAnnonces() async {
    try {
      final res = await _dio.get('/accueil');
      if (res.data['status'] == true && res.data['annonces'] != null) {
        return (res.data['annonces'] as List)
            .map((json) => Annonce.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Erreur annonces: $e');
    }
    return [];
  }

  Future<List<Evenement>> fetchEvenements() async {
    try {
      final res = await _dio.get('/evenements');
      if (res.data['status'] == true && res.data['evenements'] != null) {
        return (res.data['evenements'] as List)
            .map((json) => Evenement.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Erreur événements: $e');
    }
    return [];
  }
}
