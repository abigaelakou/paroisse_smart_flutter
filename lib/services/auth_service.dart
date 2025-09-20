import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://www.paroissesmart.com/api';
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'user_name';
  static const _paroisseNomKey = 'paroisse_nom';
  static const _paroisseIdKey = 'paroisse_id';
  static const Duration timeoutDuration = Duration(seconds: 10);

  final Dio _dio;

  AuthService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Accept': 'application/json'},
          receiveTimeout: timeoutDuration,
          connectTimeout: timeoutDuration,
        ),
      );
  static bool debug = kDebugMode;

  // ---------------- LOGIN ---------------- //
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      _logResponse('login', response);

      if (response.data['status'] == true) {
        final token = response.data['token'];
        final user = User.fromJson(response.data['user']);
        await saveToken(token);
        await saveUserData(user);
        return user;
      } else {
        throw response.data['message'] ?? 'Erreur inconnue';
      }
    } on DioException catch (e) {
      throw 'Erreur login : ${e.response?.data['message'] ?? e.message}';
    } catch (e) {
      throw 'Erreur inattendue login : $e';
    }
  }

  // ---------------- REGISTER ---------------- //
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
      final response = await _dio.post(
        '/auth/register-paroissien',
        data: {
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
        },
      );

      _logResponse('registerParoissien', response);

      return response.data['status'] == true;
    } on DioException catch (e) {
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

  // ---------------- FETCH ME ---------------- //
  Future<User> fetchMe() async {
    final token = await getToken();
    if (token == null) throw 'Utilisateur non connecté';

    try {
      final response = await _dio.get(
        '/me',
        options: Options(headers: _authHeader(token)),
      );

      _logResponse('fetchMe', response);

      final user = User.fromJson(response.data['user']);
      await saveUserData(user);
      return user;
    } on DioException catch (e) {
      throw 'Erreur fetchMe : ${e.response?.data['message'] ?? e.message}';
    } catch (e) {
      throw 'Erreur inattendue fetchMe : $e';
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
    await prefs.setInt(_paroisseIdKey, user.paroisseId);
  }

  Future<String?> getUserName() async =>
      (await SharedPreferences.getInstance()).getString(_userNameKey);

  Future<String?> getParoisseNom() async =>
      (await SharedPreferences.getInstance()).getString(_paroisseNomKey);

  Future<int?> getParoisseId() async =>
      (await SharedPreferences.getInstance()).getInt(_paroisseIdKey);

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_paroisseNomKey);
    await prefs.remove(_paroisseIdKey);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<void> setParoisseNom(String nom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('paroisse', nom);
  }

  Future<void> setParoisseId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('paroisseId', id);
  }

  // ---------------- HELPERS ---------------- //
  Map<String, String> _authHeader(String token) => {
    'Authorization': 'Bearer $token',
  };

  void _logResponse(String tag, Response response) {
    if (debug) {
      debugPrint('[$tag] Status: ${response.statusCode}');
      debugPrint('[$tag] Body: ${response.data}');
    }
  }
}
