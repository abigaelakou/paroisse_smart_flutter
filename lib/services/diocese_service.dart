import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/diocese.dart';

class DioceseService {
  final String baseUrl =
      '[https://www.paroissesmart.com/api](https://www.paroissesmart.com/api)';

  Future<List<Diocese>> fetchDioceses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/dioceses'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['dioceses'] ?? [];
        return list.map((e) => Diocese.fromJson(e)).toList();
      } else {
        throw Exception(
          'Erreur lors du chargement des diocèses (${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception("Pas de connexion Internet");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }

  Future<List<Diocese>> fetchDiocesesByPays(int paysId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/dioceses/pays/$paysId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['dioceses'] ?? [];
        return list.map((e) => Diocese.fromJson(e)).toList();
      } else {
        throw Exception(
          'Erreur lors du chargement des diocèses par pays (${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception("Pas de connexion Internet");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }
}
