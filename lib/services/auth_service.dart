import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://a9cb0983460d.ngrok-free.app/api';
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'user_name';
  static const _paroisseNomKey = 'paroisse_nom';
  static const _paroisseIdKey = 'paroisse_id';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'Accept': 'application/json'},
  ));

  // ---------------- AUTH ---------------- //

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] == true) {
        final token = response.data['token'];
        final user = User.fromJson(response.data['user']);

        await saveToken(token);
        await saveUserData(user);

        return {'token': token, 'user': user};
      }
    } catch (e) {
      debugPrint('Erreur login: $e');
    }
    return null;
  }

  Future<bool> registerParoissien({
    required String name,
    required String email,
    required String contact,
    required String password,
    required String passwordConfirmation,
    required int paroisseId,
    required String sexe,
    required String situationMatrimoniale,
    required String dateNaiss,
    required List<String> sacrementsRecus,
  }) async {
    try {
      final response = await _dio.post('/auth/register-paroissien', data: {
        'name': name,
        'email': email,
        'contact': contact,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'paroisse_id': paroisseId,
        'sexe': sexe,
        'situation_matrimoniale': situationMatrimoniale,
        'date_naiss': dateNaiss,
        'sacrement_recu': sacrementsRecus,
      });

      return response.data['status'] == true;
    } on DioError catch (e) {
      if (e.response?.statusCode == 409) {
        throw e.response?.data['message'] ?? 'Ce compte existe déjà.';
      } else if (e.response?.statusCode == 422) {
        throw 'Données invalides : ${e.response?.data['message']}';
      } else {
        throw 'Erreur serveur : ${e.message}';
      }
    } catch (e) {
      throw 'Erreur inattendue : $e';
    }
  }

  Future<bool> checkIfUserExists({
    required String email,
    required String contact,
  }) async {
    try {
      final response = await _dio.post('/checkUserExists', data: {
        'email': email,
        'contact': contact,
      });
      return response.data['exists'] == true;
    } catch (e) {
      print('Erreur vérification utilisateur existant: $e');
      return false;
    }
  }

  // ---------------- UTILISATEUR ---------------- //

  Future<User?> fetchMe(String token) async {
    try {
      final response = await _dio.get(
        '/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        await saveUserData(user);
        return user;
      }
    } catch (e) {
      debugPrint('Erreur fetchMe: $e');
    }
    return null;
  }

  Future<void> refreshUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        await saveUserData(user);
      }
    } catch (e) {
      debugPrint('Erreur refreshUserData: $e');
    }
  }

  // ---------------- SHARED PREFERENCES ---------------- //

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_paroisseNomKey, user.paroisseNom ?? '');
    await prefs.setInt(_paroisseIdKey, user.paroisseId ?? 0);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getParoisseNom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_paroisseNomKey);
  }

  Future<int?> getParoisseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_paroisseIdKey);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<void> setParoisseNom(String paroisseNom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paroisseNomKey, paroisseNom);
  }

  Future<void> setParoisseId(int paroisseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_paroisseIdKey, paroisseId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_paroisseNomKey);
    await prefs.remove(_paroisseIdKey);
  }
}
