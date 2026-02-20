import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DemandeMesseService {
  static const String baseUrl = 'https://www.paroissesmart.com/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// Activer/désactiver les logs pour le debug
  static bool debug = kDebugMode;

  // -----------------------------
  // 📌 Types de messe
  // -----------------------------
  static Future<List<Map<String, dynamic>>> fetchTypesMesse(
    String token,
    int paroisseId,
  ) async {
    final uri = Uri.parse('$baseUrl/type-messes/$paroisseId');
    try {
      final response = await http
          .get(uri, headers: _authHeader(token))
          .timeout(timeoutDuration);

      _logResponse('fetchTypesMesse', response);

      final data = _safeJsonDecode(response.body, fallback: {});
      if (response.statusCode == 200 && data['types'] != null) {
        return List<Map<String, dynamic>>.from(data['types']);
      } else {
        throw Exception(
          'Erreur chargement types de messe (${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw Exception('Temps d’attente dépassé pour fetchTypesMesse');
    } catch (e) {
      throw Exception('fetchTypesMesse échoué : $e');
    }
  }

  // -----------------------------
  // 📌 Types d’intention
  // -----------------------------
  static Future<List<Map<String, dynamic>>> fetchTypesIntention(
    String token,
    int paroisseId,
  ) async {
    final uri = Uri.parse('$baseUrl/type-intentions/$paroisseId');
    try {
      final response = await http
          .get(uri, headers: _authHeader(token))
          .timeout(timeoutDuration);

      _logResponse('fetchTypesIntention', response);

      final data = _safeJsonDecode(response.body, fallback: {});
      return List<Map<String, dynamic>>.from(data['types'] ?? []);
    } on TimeoutException {
      throw Exception('Temps d’attente dépassé pour fetchTypesIntention');
    } catch (e) {
      throw Exception('fetchTypesIntention échoué : $e');
    }
  }

  // -----------------------------
  // 📌 Envoyer une demande
  // -----------------------------
  static Future<Map<String, dynamic>> envoyerDemandeMesse({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('$baseUrl/messes');
    try {
      final response = await http
          .post(
            uri,
            headers: _authHeader(token, json: true),
            body: jsonEncode(data),
          )
          .timeout(timeoutDuration);

      _logResponse('envoyerDemandeMesse', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _safeJsonDecode(response.body, fallback: {});
      } else {
        throw Exception(
          "Erreur enregistrement demande (${response.statusCode})",
        );
      }
    } on TimeoutException {
      throw Exception('Temps d’attente dépassé pour envoyerDemandeMesse');
    } catch (e) {
      throw Exception('envoyerDemandeMesse échoué : $e');
    }
  }

  // -----------------------------
  // 📌 Mes demandes
  // -----------------------------
  static Future<List<Map<String, dynamic>>> fetchMesDemandes(
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/mes-demandes');
    try {
      final response = await http
          .get(uri, headers: _authHeader(token))
          .timeout(timeoutDuration);

      _logResponse('fetchMesDemandes', response);

      final data = _safeJsonDecode(response.body, fallback: {});
      return List<Map<String, dynamic>>.from(data['messes'] ?? []);
    } on TimeoutException {
      throw Exception('Temps d’attente dépassé pour fetchMesDemandes');
    } catch (e) {
      throw Exception('fetchMesDemandes échoué : $e');
    }
  }

  // -----------------------------
  // 🔧 Helpers
  // -----------------------------
  static Map<String, String> _authHeader(String token, {bool json = false}) {
    final headers = {'Authorization': 'Bearer $token'};
    if (json) headers['Content-Type'] = 'application/json';
    return headers;
  }

  static dynamic _safeJsonDecode(String source, {dynamic fallback}) {
    try {
      return jsonDecode(source);
    } catch (e) {
      if (debug) debugPrint('⚠️ Erreur JSON: $e');
      return fallback;
    }
  }

  static void _logResponse(String tag, http.Response response) {
    if (debug) {
      debugPrint('[$tag] Status code: ${response.statusCode}');
      debugPrint('[$tag] Body: ${response.body}');
    }
  }
}
