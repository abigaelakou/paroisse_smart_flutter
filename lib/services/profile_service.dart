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
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue fetchUser: $e\n$stack');
      }
      rethrow;
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
      throw e.response?.data['message'] ??
          'Erreur lors du changement de mot de passe';
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue changePassword: $e\n$stack');
      }
      rethrow;
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

  /// Met à jour les informations du profil utilisateur
  Future<String> updateProfile({
    required String name,
    required String email,
    required String contact,
    required String sexe,
    required String situation,
    required String dateNaissance,
    required List<String> sacrements,
    required int paroisseId,
  }) async {
    try {
      final response = await _dio.put(
        '/update-profile',
        data: {
          'name': name,
          'email': email,
          'contact': contact,
          'sexe': sexe,
          'situation_matrimoniale': situation,
          'date_naiss': dateNaissance,
          'sacrement_recu': sacrements,
          'paroisse_id': paroisseId,
        },
      );

      if (kDebugMode) {
        debugPrint('✅ updateProfile: ${response.data}');
      }

      return response.data['message'] ?? 'Profil mis à jour avec succès';
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Erreur API updateProfile: ${e.response?.data ?? e.message}',
        );
      }

      // Gestion des erreurs spécifiques
      if (e.response?.statusCode == 422) {
        throw e.response?.data['message'] ??
            'Données de validation incorrectes';
      } else if (e.response?.statusCode == 409) {
        throw e.response?.data['message'] ??
            'Conflit: email ou contact déjà utilisé';
      }

      throw e.response?.data['message'] ??
          'Erreur lors de la mise à jour du profil';
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Erreur inattendue updateProfile: $e\n$stack');
      }
      rethrow;
    }
  }
}
