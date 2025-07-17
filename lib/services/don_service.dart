import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/don.dart';

class DonService {
  static const String baseUrl = 'https://a9cb0983460d.ngrok-free.app/api';

  static Future<List<Don>> fetchMesDons(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mes-dons'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['dons'] as List).map((e) => Don.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des dons');
    }
  }

  static Future<Map<String, dynamic>> faireUnDon(
      Map<String, dynamic> donData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dons'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(donData),
      
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.body);
      throw Exception('Echec de l\'enregistrement du don');
    }
  }


    static Future<List<Map<String, dynamic>>> fetchTypesDon(String token, int paroisseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/types-don'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['types'] ?? []);
    } else {
      throw Exception("Erreur lors de la récupération des types de don");
    }
  }
}

