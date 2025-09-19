import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pain_du_jour.dart';
import '../models/annonce.dart';
import '../models/evenement.dart';

class HomeService {
  final Dio _dio;
  static bool debug = kDebugMode;

  HomeService(this._dio);

  /// ---------------- Pain du Jour ----------------
  Future<PainDuJour?> fetchPainDuJour() async {
    try {
      final response = await _dio.get('/pain-du-jour');
      _log('fetchPainDuJour', response);

      if (response.statusCode == 200 &&
          response.data['status'] == true &&
          response.data['pain'] != null) {
        return PainDuJour.fromJson(response.data['pain']);
      }
    } catch (e) {
      debugPrint("⚠️ Erreur fetchPainDuJour : $e");
    }
    return null;
  }

  /// ---------------- Annonces ----------------
  Future<List<Annonce>> fetchAnnonces({required int page}) async {
    try {
      final res = await _dio.get('/accueil', queryParameters: {'page': page});
      _log('fetchAnnonces', res);

      if (res.data['status'] == true && res.data['annonces'] != null) {
        return (res.data['annonces'] as List)
            .map((json) => Annonce.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ Erreur fetchAnnonces: $e');
    }
    return [];
  }

  /// ---------------- Événements ----------------
  Future<List<Evenement>> fetchEvenements({required int page}) async {
    try {
      final res = await _dio.get(
        '/evenements',
        queryParameters: {'page': page},
      );
      _log('fetchEvenements', res);

      if (res.data['status'] == true && res.data['evenements'] != null) {
        return (res.data['evenements'] as List)
            .map((json) => Evenement.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ Erreur fetchEvenements: $e');
    }
    return [];
  }

  /// ---------------- Logs ----------------
  void _log(String tag, Response response) {
    if (debug) {
      debugPrint('[$tag] Status code: ${response.statusCode}');
      debugPrint('[$tag] Data: ${response.data}');
    }
  }
}
