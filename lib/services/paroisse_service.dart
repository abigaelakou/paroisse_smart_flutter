import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Paroisse {
  final int id;
  final String nom;

  Paroisse({required this.id, required this.nom});

  factory Paroisse.fromJson(Map<String, dynamic> json) {
    return Paroisse(
      id: json['id'],
      nom: json['nom_paroisse'] ?? 'Paroisse inconnue',
    );
  }
}

class ParoisseService {
  final String baseUrl = 'https://www.paroissesmart.com/api';

  /// Récupère la liste des paroisses actives
  Future<List<Paroisse>> fetchParoissesActives() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/paroisses-actives'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['paroisses'] ?? [];
        return list.map((e) => Paroisse.fromJson(e)).toList();
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ fetchParoissesActives: status ${response.statusCode}');
        }
        throw Exception(
          'Erreur lors du chargement des paroisses (${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception("Pas de connexion Internet");
    } on FormatException catch (e) {
      throw Exception("Erreur de format JSON : $e");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }
}
