import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import '../models/inscription_catechese.dart';
import '../models/catechumene.dart';
import '../models/niveau.dart';
import '../models/session.dart';
import '../models/paiement_catechese.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatecheseService {
  final String token;
  late final Dio _dio;

  CatecheseService({required this.token}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://www.paroissesmart.com/api',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// 🔹 Récupérer la liste des catéchumènes d'une paroisse
  Future<List<Catechumene>> fetchCatechumenes(int paroisseId) async {
    try {
      final response = await _dio.get('/catechumenes/$paroisseId');

      final data = response.data as List? ?? [];
      return data.map((e) => Catechumene.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur fetchCatechumenes: $e');
    }
  }

  /// 🔹 Récupérer les niveaux catéchétiques
  Future<List<NiveauCatechetique>> fetchNiveaux() async {
    try {
      final response = await _dio.get('/niveaux-catechetiques');

      final data = response.data as List? ?? [];
      return data.map((e) => NiveauCatechetique.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur fetchNiveaux: $e');
    }
  }

  /// 🔹 Récupérer les sessions catéchétiques
  Future<List<SessionCatechese>> fetchSessions() async {
    try {
      final response = await _dio.get('/sessions-catechese');

      final data = response.data as List? ?? [];
      return data.map((e) => SessionCatechese.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur fetchSessions: $e');
    }
  }

  /// 🔹 Créer une inscription
  Future<InscriptionCatechese> inscrireCatechumene({
    required String annee,
    required DateTime dateInscription,
    required int catechumeneId,
    required int niveauId,
    required int sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '/inscriptions',
        data: {
          'annee_catechetique': annee,
          'date_inscription': dateInscription.toIso8601String(),
          'id_catechumene': catechumeneId,
          'id_niveau': niveauId,
          'id_session': sessionId,
        },
      );

      final data = response.data['inscription'] ?? {};
      return InscriptionCatechese.fromJson(data);
    } catch (e) {
      throw Exception('Erreur inscrireCatechumene: $e');
    }
  }

  /// 🔹 Récupérer les détails d'une inscription (inclut paiement si payé)
  Future<InscriptionCatechese> fetchInscriptionDetails(
    int inscriptionId,
  ) async {
    try {
      final response = await _dio.get('/paiement-inscription/$inscriptionId');

      final data = response.data ?? {};
      return InscriptionCatechese.fromJson(data);
    } catch (e) {
      throw Exception('Erreur fetchInscriptionDetails: $e');
    }
  }

  /// 🔹 Récupérer uniquement les paiements de l'utilisateur connecté
  Future<List<PaiementCatechese>> fetchPaiements() async {
    try {
      final response = await _dio.get("/liste-paiements");

      if (response.statusCode == 200) {
        final data = response.data['paiements'] as List? ?? [];
        return data.map((json) => PaiementCatechese.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur API: code ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur fetchPaiements: ${e.message}');
    } catch (e) {
      throw Exception('Erreur fetchPaiements: $e');
    }
  }
  //static const String _cacheKey = "paiements_catechese";

  /// 🔹 Récupération hybride (cache + API) avec recuUrl
  // Future<List<PaiementCatechese>> fetchPaiements() async {
  //   List<PaiementCatechese> paiements = [];

  //   // 1️⃣ Charger depuis cache
  //   final prefs = await SharedPreferences.getInstance();
  //   final cached = prefs.getString(_cacheKey);
  //   if (cached != null) {
  //     final List<dynamic> decoded = jsonDecode(cached);
  //     paiements = decoded.map((e) => PaiementCatechese.fromJson(e)).toList();
  //   }

  //   try {
  //     // 2️⃣ Charger depuis API
  //     final response = await _dio.get("/liste-paiements");

  //     if (response.statusCode == 200) {
  //       final data = response.data;

  //       List<PaiementCatechese> freshPaiements = [];
  //       if (data is List) {
  //         freshPaiements = data
  //             .map((json) => PaiementCatechese.fromJson(json))
  //             .toList();
  //       } else if (data is Map) {
  //         if (data.containsKey('data')) {
  //           freshPaiements = (data['data'] as List)
  //               .map((json) => PaiementCatechese.fromJson(json))
  //               .toList();
  //         } else if (data.containsKey('paiements')) {
  //           freshPaiements = (data['paiements'] as List)
  //               .map((json) => PaiementCatechese.fromJson(json))
  //               .toList();
  //         }
  //       }

  //       // 3️⃣ Mettre à jour cache
  //       await prefs.setString(
  //         _cacheKey,
  //         jsonEncode(freshPaiements.map((p) => p.toJson()).toList()),
  //       );

  //       paiements = freshPaiements;
  //     }
  //   } on DioException catch (_) {
  //     // si API échoue → on garde le cache
  //   }

  //   return paiements;
  // }

  /// 🔹 Effectuer le paiement d'une inscription et récupérer l'URL du reçu
  Future<String> payerInscription({
    required int inscriptionId,
    required double montant,
    required String modePaiement,
    required String contact,
    required String paymentStatus,
  }) async {
    final response = await _dio.post(
      '/paiement-inscription',
      data: {
        'id_inscription': inscriptionId,
        'montant': montant,
        'mode_paiement': modePaiement,
        'contact': contact,
        'payment_status': paymentStatus,
      },
    );

    // L'API renvoie directement recu_url
    final recuUrl = response.data['recu_url'] as String?;
    if (recuUrl == null) {
      throw Exception("Impossible de récupérer le reçu.");
    }

    return recuUrl;
  }
}
