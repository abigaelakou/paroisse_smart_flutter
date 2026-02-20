import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pain_du_jour_item.dart';

class PainDuJourService {
  final Dio dio;

  PainDuJourService(this.dio);

  /// Récupère l'historique des pains du jour
  Future<List<PainDuJourItem>> fetchHistorique() async {
    try {
      final response = await dio.get('/mes-pains');

      if (response.statusCode == 200 &&
          response.data['status'] == true &&
          response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => PainDuJourItem.fromJson(json))
            .toList();
      } else {
        if (kDebugMode) {
          debugPrint(
            '⚠️ fetchHistorique: réponse invalide ou vide (${response.statusCode})',
          );
        }
        return [];
      }
    } on DioError catch (e) {
      if (kDebugMode) debugPrint('Erreur Dio fetchHistorique: ${e.message}');
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Erreur inattendue fetchHistorique: $e');
      return [];
    }
  }
}
