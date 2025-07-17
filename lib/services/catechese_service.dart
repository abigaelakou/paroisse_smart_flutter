import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/inscription_catechese.dart';
import '../models/catechumene.dart';
import '../models/niveau.dart';
import '../models/session.dart';
import '../models/paiement_catechese.dart';

class CatecheseService {
  final String token;
  static const String baseUrl = 'https://a9cb0983460d.ngrok-free.app/api';

  CatecheseService({required this.token});

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<InscriptionCatechese> fetchInscriptionDetails(int id) async {
    final response = await _get('/paiement-inscription/$id');
    return InscriptionCatechese.fromJson(jsonDecode(response.body));
  }

  Future<List<Catechumene>> fetchCatechumenes(int paroisseId) async {
    final response = await _get('/catechumenes/$paroisseId');
    final List data = jsonDecode(response.body);
    return data.map((e) => Catechumene.fromJson(e)).toList();
  }

  Future<List<NiveauCatechetique>> fetchNiveaux() async {
    final response = await _get('/niveaux-catechetiques');
    final List data = jsonDecode(response.body);
    return data.map((e) => NiveauCatechetique.fromJson(e)).toList();
  }

  Future<List<SessionCatechese>> fetchSessions() async {
    final response = await _get('/sessions-catechese');
    final List data = jsonDecode(response.body);
    return data.map((e) => SessionCatechese.fromJson(e)).toList();
  }

  Future<InscriptionCatechese> inscrireCatechumene({
    required String annee,
    required DateTime dateInscription,
    required int catechumeneId,
    required int niveauId,
    required int sessionId,
  }) async {
    final response = await _post('/inscriptions', body: {
      'annee_catechetique': annee,
      'date_inscription': dateInscription.toIso8601String(),
      'id_catechumene': catechumeneId,
      'id_niveau': niveauId,
      'id_session': sessionId,
    });

    final decoded = jsonDecode(response.body);
    return InscriptionCatechese.fromJson(decoded['inscription']);
  }

  Future<String> payerInscription({
    required int inscriptionId,
    required double montant,
    required String modePaiement,
    required String contact,
  }) async {
    final response = await _post('/paiement-inscription', body: {
      'id_inscription': inscriptionId,
      'montant': montant,
      'mode_paiement': modePaiement.toLowerCase(),
      'contact': contact.isEmpty ? null : contact,
      'payment_status': 'Payé',
    });

    final data = jsonDecode(response.body);
    return data['recu_url'];
  }

  Future<List<PaiementCatechese>> fetchPaiements() async {
    final response = await _get('/liste-paiements');
    final data = jsonDecode(response.body);
    return (data['paiements'] as List)
        .map((e) => PaiementCatechese.fromJson(e))
        .toList();
  }

  // ---------------------------------------
  // 🔧 Helpers pour factoriser les requêtes
  // ---------------------------------------

  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    _handleErrors(response);
    return response;
  }

  Future<http.Response> _post(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));
    _handleErrors(response);
    return response;
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    try {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? 'Erreur inconnue';
      throw Exception("(${response.statusCode}) $message");
    } catch (e) {
      throw Exception("(${response.statusCode}) Erreur de traitement");
    }
  }
}
