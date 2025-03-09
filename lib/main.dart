import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'application/auth/auth_bloc.dart';
import 'application/auth/auth_event.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/providers/project_repository_provider.dart';
import 'infrastructure/providers/dio_provider.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Créer le DioProvider avec l'intercepteur d'authentification
  final dioProvider = await DioProvider.create(
    child: Container(), // Placeholder, sera remplacé plus tard
  );

  final authRepository = AuthRepositoryImpl(dioProvider.dio, await SharedPreferences.getInstance());
  final authBloc = AuthBloc(authRepository)..add(CheckAuthStatusEvent());
  final appRouter = AppRouter.getRouter(authBloc);

  // Créer l'arbre de widgets avec tous les providers nécessaires
  final app = await ProjectRepositoryProvider.create(
    dio: dioProvider.dio,
    child: DioProvider(
      dio: dioProvider.dio,
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
    ),
  );

  runApp(app);
}
