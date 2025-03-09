import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../interceptors/auth_interceptor.dart';

class DioProvider extends InheritedWidget {
  final Dio dio;

  const DioProvider({
    super.key,
    required this.dio,
    required super.child,
  });

  static Dio of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<DioProvider>();
    if (provider == null) {
      throw Exception('DioProvider not found in widget tree');
    }
    return provider.dio;
  }

  @override
  bool updateShouldNotify(DioProvider oldWidget) {
    return dio != oldWidget.dio;
  }

  static Future<DioProvider> create({
    required Widget child,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      validateStatus: (status) => status! < 500,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Configuration pour les requêtes CORS
      extra: {
        'withCredentials': false, // Pas de credentials comme spécifié dans les MEMORIES
      },
    ));
    
    // Ajouter l'intercepteur d'authentification
    dio.interceptors.add(AuthInterceptor(prefs));
    
    // Ajouter un intercepteur pour les logs
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
    
    return DioProvider(
      dio: dio,
      child: child,
    );
  }
}
