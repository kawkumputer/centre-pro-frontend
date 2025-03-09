import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'application/auth/auth_bloc.dart';
import 'application/auth/auth_event.dart';
import 'domain/repositories/auth_repository.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation des dépendances
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio()
    ..options.baseUrl = ApiConfig.baseUrl
    ..options.headers = ApiConfig.getHeaders()
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  
  // Initialisation du repository et du bloc
  final authRepository = AuthRepositoryImpl(dio, prefs);
  final authBloc = AuthBloc(authRepository)..add(CheckAuthStatusEvent());
  
  runApp(MyApp(
    authRepository: authRepository,
    authBloc: authBloc,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AuthBloc authBloc;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: authBloc,
        ),
      ],
      child: MaterialApp.router(
        title: 'Centre Éducatif',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.getRouter(authBloc),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}
