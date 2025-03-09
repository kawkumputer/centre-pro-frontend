import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/home/home_page.dart';
import '../pages/projects/projects_page.dart';
import '../pages/projects/project_form_page.dart';
import '../pages/projects/project_details_page.dart';
import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_state.dart';
import '../../application/auth/auth_event.dart';
import '../../domain/models/project.dart';

class AppRouter {
  static GoRouter getRouter(AuthBloc authBloc) {
    return GoRouter(
      refreshListenable: _AuthStateNotifier(authBloc),
      initialLocation: '/',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoginRoute = state.matchedLocation == '/auth/login';
        final isSignupRoute = state.matchedLocation == '/auth/signup';

        // Vérifier l'état d'authentification
        if (authState is AuthInitial) {
          authBloc.add(CheckAuthStatusEvent());
          return null;
        }

        if (authState is AuthLoading) {
          return null;
        }

        if (authState is AuthError) {
          return '/auth/login';
        }

        final isAuthenticated = authState is Authenticated;
        
        // Redirection selon l'état d'authentification
        if (!isAuthenticated && !isLoginRoute && !isSignupRoute) {
          return '/auth/login';
        }
        if (isAuthenticated && (isLoginRoute || isSignupRoute)) {
          return '/'; // Rediriger vers la page d'accueil après connexion
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: '/auth/signup',
          builder: (context, state) => SignupPage(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const ProjectFormPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final projectId = state.pathParameters['id']!;
                return ProjectDetailsPage(projectId: projectId);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final projectId = state.pathParameters['id']!;
                    return ProjectFormPage(projectId: projectId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// Notifier pour rafraîchir le routeur quand l'état d'authentification change
class _AuthStateNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  AuthState? _previousState;

  _AuthStateNotifier(this._authBloc) {
    _authBloc.stream.listen((AuthState state) {
      if (state != _previousState) {
        _previousState = state;
        notifyListeners();
      }
    });
  }
}
