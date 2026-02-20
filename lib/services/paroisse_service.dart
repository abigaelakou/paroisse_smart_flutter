import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:paroisse_smart_flutter/models/paroisse.dart';

class ParoisseService {
  final String baseUrl = 'https://www.paroissesmart.com/api';

  /// Récupère toutes les paroisses actives (status = 1) avec leurs relations
  Future<List<Paroisse>> fetchParoissesActives() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/paroisses-actives'))
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('✅ fetchParoissesActives: Status ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Gérer les deux formats possibles de réponse
        List list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['paroisses'] != null) {
          list = data['paroisses'];
        } else {
          throw Exception('Format de réponse inattendu');
        }

        final paroisses = list
            .map((e) => Paroisse.fromJson(e as Map<String, dynamic>))
            .where((paroisse) => paroisse.isActive)
            .toList();

        if (kDebugMode) {
          debugPrint('✅ ${paroisses.length} paroisses actives récupérées');
        }

        return paroisses;
      } else {
        throw Exception(
          'Erreur lors du chargement des paroisses (${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception("Pas de connexion Internet");
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur de format JSON : $e');
      }
      throw Exception("Erreur de format JSON : $e");
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur inattendue fetchParoissesActives: $e');
      }
      throw Exception("Erreur inattendue : $e");
    }
  }

  /// Récupère les paroisses d'un diocèse spécifique
  Future<List<Paroisse>> fetchParoissesByDiocese(int dioceseId) async {
    try {
      final allParoisses = await fetchParoissesActives();
      return allParoisses
          .where((p) => p.dioceseId == dioceseId)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur fetchParoissesByDiocese: $e');
      }
      rethrow;
    }
  }

  /// Récupère une paroisse spécifique par son ID
  Future<Paroisse?> fetchParoisseById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/paroisses/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Paroisse.fromJson(data);
      }
    } on SocketException {
      throw Exception("Pas de connexion Internet");
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur fetchParoisseById: $e');
      }
    }
    return null;
  }
}