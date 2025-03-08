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
      developer.log('URL: ${_dio.options.baseUrl}${ApiConfig.login}', name: 'Auth');
      
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

      developer.log('Réponse reçue: ${response.statusCode}', name: 'Auth');
      developer.log('Headers: ${response.headers}', name: 'Auth');
      developer.log('Data: ${response.data}', name: 'Auth');

      if (response.statusCode != 200) {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }

      // Vérifier si la réponse contient un token
      final token = response.data['token'] as String?;
      developer.log('Token trouvé dans la réponse: ${token != null}', name: 'Auth');
      
      if (token == null) {
        throw Exception('Token non trouvé dans la réponse');
      }

      // Sauvegarder le token
      await _prefs.setString(_tokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
      developer.log('Token sauvegardé et ajouté aux headers', name: 'Auth');

      // Créer un utilisateur temporaire en attendant l'implémentation de /users/me
      final user = User(
        id: 0, // ID temporaire
        firstName: '',
        lastName: '',
        email: email,
        role: UserRole.USER,
      );
      
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      developer.log('Utilisateur temporaire créé et sauvegardé', name: 'Auth');
      
      return user;
    } on DioException catch (e) {
      developer.log(
        'Dio error: ${e.toString()}\nResponse: ${e.response?.data}\nStatus: ${e.response?.statusCode}', 
        name: 'Auth', 
        error: e
      );
      throw _handleDioError(e);
    } catch (e) {
      developer.log('Error: ${e.toString()}', name: 'Auth', error: e);
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<User> signup(String firstName, String lastName, String email, String password) async {
    try {
      developer.log('Tentative d\'inscription pour: $email', name: 'Auth');
      developer.log('URL: ${_dio.options.baseUrl}${ApiConfig.signup}', name: 'Auth');
      
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

      developer.log('Réponse reçue: ${response.statusCode}', name: 'Auth');
      developer.log('Headers: ${response.headers}', name: 'Auth');
      developer.log('Data: ${response.data}', name: 'Auth');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'inscription: ${response.statusCode}');
      }

      // Vérifier si la réponse contient un token
      final token = response.data['token'] as String?;
      developer.log('Token trouvé dans la réponse: ${token != null}', name: 'Auth');
      
      if (token == null) {
        throw Exception('Token non trouvé dans la réponse');
      }

      // Sauvegarder le token
      await _prefs.setString(_tokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
      developer.log('Token sauvegardé et ajouté aux headers', name: 'Auth');

      // Créer un utilisateur avec les informations fournies
      final user = User(
        id: 0, // ID temporaire
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: UserRole.USER,
      );
      
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      developer.log('Utilisateur créé et sauvegardé', name: 'Auth');
      
      return user;
    } on DioException catch (e) {
      developer.log(
        'Dio error: ${e.toString()}\nResponse: ${e.response?.data}\nStatus: ${e.response?.statusCode}', 
        name: 'Auth', 
        error: e
      );
      throw _handleDioError(e);
    } catch (e) {
      developer.log('Error: ${e.toString()}', name: 'Auth', error: e);
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
      final userStr = _prefs.getString(_userKey);
      final token = _prefs.getString(_tokenKey);
      
      developer.log('Getting current user - Token exists: ${token != null}', name: 'Auth');
      
      if (userStr != null && token != null) {
        final userMap = jsonDecode(userStr) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      developer.log('Error getting current user: ${e.toString()}', name: 'Auth', error: e);
      await logout();
      return null;
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
    return Exception('Erreur de connexion au serveur');
  }
}
