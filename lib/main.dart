import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'application/auth/auth_bloc.dart';
import 'application/auth/auth_event.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/providers/project_repository_provider.dart';
import 'presentation/routes/app_router.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio()
    ..options.baseUrl = ApiConfig.baseUrl
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
      ),
    );

  final authRepository = AuthRepositoryImpl(dio, await SharedPreferences.getInstance());
  final authBloc = AuthBloc(authRepository)..add(CheckAuthStatusEvent());
  final appRouter = AppRouter.getRouter(authBloc);

  final app = await ProjectRepositoryProvider.create(
    dio: dio,
    child: BlocProvider(
      create: (_) => authBloc,
      child: MaterialApp.router(
        title: 'Centre Éducatif',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    ),
  );

  runApp(app);
}
