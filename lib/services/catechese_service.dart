import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/inscription_catechese.dart';
import '../models/catechumene.dart';
import '../models/niveau.dart';
import '../models/session.dart';
import '../models/paiement_catechese.dart';

class CatecheseService {
  final String token;
  final String baseUrl;

  CatecheseService({
    required this.token,
    this.baseUrl = 'https://www.paroissesmart.com/api',
  });

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // -----------------------------
  // 📌 Méthodes publiques (API)
  // -----------------------------

  Future<InscriptionCatechese?> fetchInscriptionDetails(int id) async {
    try {
      final response = await _get('/paiement-inscription/$id');
      final decoded = _safeJsonDecode(response.body);
      if (decoded != null) return InscriptionCatechese.fromJson(decoded);
    } catch (e) {
      debugPrint("Erreur fetchInscriptionDetails: $e");
    }
    return null;
  }

  Future<List<Catechumene>> fetchCatechumenes(int paroisseId) async {
    try {
      final response = await _get('/catechumenes/$paroisseId');
      final List data = _safeJsonDecode(response.body, fallback: []);
      return data.map((e) => Catechumene.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Erreur fetchCatechumenes: $e");
    }
    return [];
  }

  Future<List<NiveauCatechetique>> fetchNiveaux() async {
    try {
      final response = await _get('/niveaux-catechetiques');
      final List data = _safeJsonDecode(response.body, fallback: []);
      return data.map((e) => NiveauCatechetique.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Erreur fetchNiveaux: $e");
    }
    return [];
  }

  Future<List<SessionCatechese>> fetchSessions() async {
    try {
      final response = await _get('/sessions-catechese');
      final List data = _safeJsonDecode(response.body, fallback: []);
      return data.map((e) => SessionCatechese.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Erreur fetchSessions: $e");
    }
    return [];
  }

  Future<InscriptionCatechese?> inscrireCatechumene({
    required String annee,
    required DateTime dateInscription,
    required int catechumeneId,
    required int niveauId,
    required int sessionId,
  }) async {
    try {
      final response = await _post(
        '/inscriptions',
        body: {
          'annee_catechetique': annee,
          'date_inscription': dateInscription.toIso8601String(),
          'id_catechumene': catechumeneId,
          'id_niveau': niveauId,
          'id_session': sessionId,
        },
      );

      final decoded = _safeJsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('inscription')) {
        return InscriptionCatechese.fromJson(decoded['inscription']);
      }
      debugPrint("Inscription non trouvée dans la réponse: $decoded");
    } catch (e) {
      debugPrint("Erreur inscrireCatechumene: $e");
    }
    return null;
  }

  Future<Map> payerInscription({
    required int inscriptionId,
    required double montant,
    required String modePaiement,
    required String contact,
  }) async {
    try {
      final response = await _post(
        '/paiement-inscription',
        body: {
          'id_inscription': inscriptionId,
          'montant': montant,
          'mode_paiement': modePaiement.toLowerCase(),
          'contact': contact.isEmpty ? null : contact,
          'payment_status': 'Payé',
        },
      );

      final data = _safeJsonDecode(response.body, fallback: {});
      if (data is Map) return data;
      debugPrint("Paiement réponse invalide: ${response.body}");
    } catch (e) {
      debugPrint("Erreur payerInscription: $e");
    }
    return {};
  }

  Future<List<PaiementCatechese>> fetchPaiements() async {
    try {
      final response = await _get('/liste-paiements');
      final data = _safeJsonDecode(response.body, fallback: {});
      if (data is Map && data.containsKey('paiements')) {
        return (data['paiements'] as List)
            .map((e) => PaiementCatechese.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("Erreur fetchPaiements: $e");
    }
    return [];
  }

  // ---------------------------------------
  // 🔧 Helpers pour factoriser les requêtes
  // ---------------------------------------

  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      _handleErrors(response);
      return response;
    } on TimeoutException {
      throw Exception("Temps d'attente dépassé pour $path");
    } catch (e) {
      debugPrint("Erreur GET $path: $e");
      rethrow;
    }
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      _handleErrors(response);
      return response;
    } on TimeoutException {
      throw Exception("Temps d'attente dépassé pour $path");
    } catch (e) {
      debugPrint("Erreur POST $path: $e");
      rethrow;
    }
  }

  // -----------------------------
  // 📌 Gestion des erreurs
  // -----------------------------

  void _handleErrors(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    try {
      final decoded = jsonDecode(response.body);
      final message = (decoded is Map && decoded['message'] != null)
          ? decoded['message']
          : 'Erreur inconnue';
      if (kDebugMode) {
        debugPrint("⚠️ Erreur API (${response.statusCode}): $message");
      }
      throw Exception("(${response.statusCode}) $message");
    } catch (_) {
      throw Exception("(${response.statusCode}) Erreur de traitement serveur");
    }
  }

  // -----------------------------
  // 📌 Safe JSON Decoder
  // -----------------------------

  dynamic _safeJsonDecode(String source, {dynamic fallback}) {
    try {
      return jsonDecode(source);
    } catch (e) {
      if (kDebugMode) debugPrint("⚠️ Erreur JSON: $e");
      return fallback;
    }
  }
}
