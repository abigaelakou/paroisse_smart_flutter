import 'dart:convert';
import 'package:http/http.dart' as http;

class DemandeMesseService {
  static const String baseUrl = 'https://www.paroissesmart.com/api';

  /// Récupérer les types de messe selon la paroisse
 static Future<List<Map<String, dynamic>>> fetchTypesMesse(String token, int paroisseId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/type-messes/$paroisseId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['types'] == null) {
      throw Exception("La clé 'types' est absente ou nulle dans la réponse.");
    }
    return List<Map<String, dynamic>>.from(data['types']);
  } else {
    throw Exception('Erreur lors du chargement des types de messe (${response.statusCode})');
  }
}


  /// Récupérer les types d’intention selon la paroisse
  static Future<List<Map<String, dynamic>>> fetchTypesIntention(String token, int paroisseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/type-intentions/$paroisseId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['types'] ?? []);
    } else {
      throw Exception('Erreur lors du chargement des types d’intention');
    }
  }

  /// Envoyer une demande de messe (avec paiement simulé)
  static Future<Map<String, dynamic>> envoyerDemandeMesse({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Erreur réponse: ${response.body}');
      throw Exception("Erreur lors de l'enregistrement de la demande de messe");
    }
  }

  /// Récupérer les demandes de l’utilisateur connecté
  static Future<List<Map<String, dynamic>>> fetchMesDemandes(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mes-demandes'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['messes'] ?? []);
    } else {
      throw Exception("Erreur lors de la récupération des demandes");
    }
  }
}
