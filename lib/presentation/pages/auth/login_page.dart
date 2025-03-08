import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_bloc.dart';
import '../../../application/auth/auth_event.dart';
import '../../../application/auth/auth_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            context.go('/home');
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CentrePro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: 'email',
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Ce champ est requis'),
                              FormBuilderValidators.email(errorText: 'Email invalide'),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'password',
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Ce champ est requis'),
                              FormBuilderValidators.minLength(6, errorText: 'Le mot de passe doit contenir au moins 6 caractères'),
                            ]),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState?.saveAndValidate() ?? false) {
                                                final values = _formKey.currentState!.value;
                                                context.read<AuthBloc>().add(
                                                  LoginEvent(
                                                    email: values['email'],
                                                    password: values['password'],
                                                  ),
                                                );
                                              }
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: state is AuthLoading
                                            ? const CircularProgressIndicator()
                                            : const Text('Se connecter'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => context.go('/signup'),
                                    child: const Text("Pas encore de compte ? S'inscrire"),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
