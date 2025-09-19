import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      } else {
        if (kDebugMode) {
          debugPrint(
            '⚠️ fetchUser: status ${response.statusCode}, data: ${response.data}',
          );
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur API fetchUser: ${e.response?.data ?? e.message}');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue fetchUser: $e\n$stack');
      }
    }
    return null;
  }

  /// Déconnecte l'utilisateur (API /logout)
  Future<bool> logout() async {
    try {
      final response = await _dio.post('/logout');
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur API déconnexion: ${e.response?.data ?? e.message}');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue déconnexion: $e\n$stack');
      }
    }
    return false;
  }

  /// Change le mot de passe de l'utilisateur
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/changePassword',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      return response.data['message'] ?? 'Mot de passe changé';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return e.response?.data['message'] ?? 'Erreur de validation';
      }
      if (kDebugMode) {
        debugPrint(
          'Erreur API changePassword: ${e.response?.data ?? e.message}',
        );
      }
      return 'Erreur lors du changement de mot de passe';
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue changePassword: $e\n$stack');
      }
      return 'Erreur inconnue';
    }
  }

  /// Met à jour le token Expo de l'utilisateur (notifications push)
  Future<void> updateExpoToken(String expoToken) async {
    try {
      await _dio.post('/updateExpoToken', data: {'expo_token': expoToken});
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur mise à jour token Expo: $e\n$stack');
      }
    }
  }
}
