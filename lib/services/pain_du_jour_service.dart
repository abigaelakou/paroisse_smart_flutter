// services/pain_du_jour_service.dart
import 'package:dio/dio.dart';
import '../models/pain_du_jour_item.dart';

class PainDuJourService {
  final Dio dio;

  PainDuJourService(this.dio);

  Future<List<PainDuJourItem>> fetchHistorique() async {
    final response = await dio.get('/mes-pains');
    if (response.statusCode == 200 && response.data['status'] == true) {
      return (response.data['data'] as List)
          .map((json) => PainDuJourItem.fromJson(json))
          .toList();
    }
    return [];
  }
}
