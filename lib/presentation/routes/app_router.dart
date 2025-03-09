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
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoginRoute = state.matchedLocation == '/login';
        final isSignupRoute = state.matchedLocation == '/signup';

        // Vérifier l'état d'authentification
        if (authState is AuthInitial) {
          authBloc.add(CheckAuthStatusEvent());
          return null;
        }

        if (authState is AuthLoading) {
          return null;
        }

        if (authState is AuthError) {
          return '/login';
        }

        final isAuthenticated = authState is Authenticated;
        
        // Redirection selon l'état d'authentification
        if (!isAuthenticated && !isLoginRoute && !isSignupRoute) {
          return '/login';
        }
        if (isAuthenticated && (isLoginRoute || isSignupRoute)) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignupPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsPage(),
        ),
        GoRoute(
          path: '/projects/new',
          builder: (context, state) => const ProjectFormPage(),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (context, state) {
            final project = state.extra as Project;
            return ProjectDetailsPage(project: project);
          },
        ),
        GoRoute(
          path: '/projects/:id/edit',
          builder: (context, state) {
            final project = state.extra as Project;
            return ProjectFormPage(project: project);
          },
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
