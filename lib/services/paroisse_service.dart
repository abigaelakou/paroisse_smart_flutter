import 'dart:convert';
import 'package:http/http.dart' as http;

class Paroisse {
  final int id;
  final String nom;

  Paroisse({required this.id, required this.nom});

  factory Paroisse.fromJson(Map<String, dynamic> json) {
    return Paroisse(
      id: json['id'],
      nom: json['nom_paroisse'],
    );
  }
}

class ParoisseService {
  final String baseUrl = 'https://a9cb0983460d.ngrok-free.app/api';

  Future<List<Paroisse>> fetchParoissesActives() async {
    final response = await http.get(Uri.parse('$baseUrl/paroisses-actives'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['paroisses'];
      return list.map((e) => Paroisse.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors du chargement des paroisses");
    }
  }
}
