import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  AuthRepositoryImpl(this._dio, this._prefs) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    final token = _prefs.getString(_tokenKey);
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => developer.log(obj.toString(), name: 'API'),
    ));
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      developer.log('Tentative de connexion pour: $email', name: 'Auth');
      
      final response = await _dio.post(
        ApiConfig.login,
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }

      final data = response.data;
      final token = data['token'] as String?;
      if (token == null) {
        throw Exception('Token non trouvé dans la réponse');
      }

      await _prefs.setString(_tokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Créer l'utilisateur à partir des données de la réponse
      final user = User.fromJson(data);

      // Sauvegarder l'utilisateur dans le cache
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));

      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<User> signup(String firstName, String lastName, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.signup,
        data: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'inscription: ${response.statusCode}');
      }

      final data = response.data;
      final token = data['token'] as String?;
      if (token == null) {
        throw Exception('Token non trouvé dans la réponse');
      }

      await _prefs.setString(_tokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Créer l'utilisateur à partir des données de la réponse
      final user = User.fromJson(data);

      // Sauvegarder l'utilisateur dans le cache
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));

      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    developer.log('Déconnexion...', name: 'Auth');
    _dio.options.headers.remove('Authorization');
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null) {
        return null;
      }

      // Essayer d'abord de récupérer depuis le cache
      final userStr = _prefs.getString(_userKey);
      if (userStr != null) {
        return User.fromJson(jsonDecode(userStr));
      }

      // Si pas en cache, récupérer depuis l'API
      return await _fetchCurrentUserDetails();
    } catch (e) {
      developer.log('Error getting current user: ${e.toString()}', name: 'Auth', error: e);
      await logout();
      return null;
    }
  }

  Future<User> _fetchCurrentUserDetails() async {
    try {
      final response = await _dio.get(
        ApiConfig.currentUser,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la récupération des données utilisateur');
      }

      final user = User.fromJson(response.data);
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    final response = error.response;
    if (response != null) {
      final data = response.data;
      if (data != null && data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null) {
          return Exception(message);
        }
      }
      return Exception('Erreur ${response.statusCode}: ${response.statusMessage}');
    }
    return Exception('Erreur de connexion: ${error.message}');
  }
}
