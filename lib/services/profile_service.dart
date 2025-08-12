import 'package:dio/dio.dart';
import '../models/user.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  /// Récupère les informations de l'utilisateur connecté
  Future<User?> fetchUser() async {
    try {
      final response = await _dio.get('/user');
      if (response.statusCode == 200 && response.data != null) {
        return User.fromJson(response.data);
      }
    } catch (e, stack) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
    }
    return null;
  }

  /// Déconnecte l'utilisateur (API /logout)
  Future<bool> logout() async {
    try {
      final response = await _dio.post('/logout');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Erreur API déconnexion : ${e.response?.data ?? e.message}');
    } catch (e) {
      print('Erreur inattendue à la déconnexion : $e');
    }
    return false;
  }

  /// Change le mot de passe de l'utilisateur
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dio.post('/changePassword', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });

      return response.data['message'] ?? 'Mot de passe changé';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return e.response?.data['message'] ?? 'Erreur de validation';
      }
      return 'Erreur lors du changement de mot de passe';
    } catch (e) {
      print('Erreur inattendue changement mot de passe : $e');
      return 'Erreur inconnue';
    }
  }

  /// Met à jour le token Expo de l'utilisateur (notifications push)
  Future<void> updateExpoToken(String expoToken) async {
    try {
      await _dio.post('/updateExpoToken', data: {
        'expo_token': expoToken,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du token Expo : $e');
    }
  }
}
