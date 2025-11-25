import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pays.dart';

class PaysService {
  final String baseUrl =
      '[https://www.paroissesmart.com/api](https://www.paroissesmart.com/api)';

  Future<List<Pays>> fetchPays() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/pays'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['pays'] ?? [];
        return list.map((e) => Pays.fromJson(e)).toList();
      } else {
        throw Exception(
          'Erreur lors du chargement des pays (${response.statusCode})',
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
