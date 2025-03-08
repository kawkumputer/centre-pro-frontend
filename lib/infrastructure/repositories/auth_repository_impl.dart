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
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      await _prefs.setString(_tokenKey, token);
      
      final user = User.fromJson(response.data['user']);
      await _prefs.setString(_userKey, user.toJson().toString());
      
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<User> signup(String firstName, String lastName, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.signup,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );

      final token = response.data['token'];
      await _prefs.setString(_tokenKey, token);
      
      final user = User.fromJson(response.data['user']);
      await _prefs.setString(_userKey, user.toJson().toString());
      
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      try {
        return User.fromJson(Map<String, dynamic>.from(
          // ignore: unnecessary_cast
          (userStr as Map<String, dynamic>)
        ));
      } catch (e) {
        await logout();
        return null;
      }
    }
    return null;
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final data = response.data;
        if (data != null && data['message'] != null) {
          return Exception(data['message']);
        }
      }
      return Exception(error.message);
    }
    return Exception('Une erreur est survenue');
  }
}
