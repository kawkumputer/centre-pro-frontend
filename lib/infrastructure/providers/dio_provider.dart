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
    ));
    
    // Ajouter l'intercepteur d'authentification
    dio.interceptors.add(AuthInterceptor(prefs));
    
    return DioProvider(
      dio: dio,
      child: child,
    );
  }
}
