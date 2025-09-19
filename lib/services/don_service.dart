import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/don.dart';

class DonService {
  static const String baseUrl = 'https://www.paroissesmart.com/api';
  static const Duration timeoutDuration = Duration(seconds: 10);
  static bool debug = kDebugMode;

  /// Vérifie la connexion Internet avant un appel API
  static Future<void> _checkInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Pas de connexion Internet');
    }
  }

  /// Récupérer la liste des dons de l’utilisateur
  static Future<List<Don>> fetchMesDons(String token) async {
    await _checkInternet();

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/mes-dons'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(timeoutDuration);

      _log('fetchMesDons', response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['dons'] as List).map((e) => Don.fromJson(e)).toList();
      } else {
        throw Exception(
          'Erreur ${response.statusCode} lors du chargement des dons',
        );
      }
    } on SocketException {
      throw Exception("Impossible de se connecter au serveur");
    } on TimeoutException {
      throw Exception("Temps d'attente dépassé pour fetchMesDons");
    } catch (e) {
      throw Exception("Erreur inattendue: $e");
    }
  }

  /// Enregistrer un nouveau don
  static Future<Map<String, dynamic>> faireUnDon(
    Map<String, dynamic> donData,
    String token,
  ) async {
    await _checkInternet();

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/dons'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(donData),
          )
          .timeout(timeoutDuration);

      _log('faireUnDon', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Échec de l\'enregistrement du don (${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception("Impossible de se connecter au serveur");
    } on TimeoutException {
      throw Exception("Temps d'attente dépassé pour faireUnDon");
    } catch (e) {
      throw Exception("Erreur inattendue: $e");
    }
  }

  /// Récupérer les types de dons disponibles
  static Future<List<Map<String, dynamic>>> fetchTypesDon(
    String token,
    int paroisseId,
  ) async {
    await _checkInternet();

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/types-don'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(timeoutDuration);

      _log('fetchTypesDon', response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['types'] ?? []);
      } else {
        throw Exception(
          "Erreur ${response.statusCode} lors de la récupération des types de don",
        );
      }
    } on SocketException {
      throw Exception("Impossible de se connecter au serveur");
    } on TimeoutException {
      throw Exception("Temps d'attente dépassé pour fetchTypesDon");
    } catch (e) {
      throw Exception("Erreur inattendue: $e");
    }
  }

  /// Logs uniquement en debug
  static void _log(String tag, http.Response response) {
    if (debug) {
      debugPrint('[$tag] Status code: ${response.statusCode}');
      debugPrint('[$tag] Body: ${response.body}');
    }
  }
}
