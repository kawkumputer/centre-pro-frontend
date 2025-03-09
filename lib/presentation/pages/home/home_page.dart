import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/auth/auth_bloc.dart';
import '../../../application/auth/auth_event.dart';
import '../../../application/auth/auth_state.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CentrePro'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is Authenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bienvenue ${state.user.firstName} ${state.user.lastName}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rôle : ${state.user.role.toString().split('.').last}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    // TODO: Ajouter les fonctionnalités principales ici
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
