import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/home/home_page.dart';
import '../../application/auth/auth_bloc.dart';
import '../../application/auth/auth_state.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is Authenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSignupRoute = state.matchedLocation == '/signup';

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
    ],
  );
}
