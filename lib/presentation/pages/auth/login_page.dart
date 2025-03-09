import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_bloc.dart';
import '../../../application/auth/auth_event.dart';
import '../../../application/auth/auth_state.dart';
import '../../../core/constants/app_constants.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            } else if (state is Authenticated) {
              context.go('/');
            }
          },
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo temporaire
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.loginTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Formulaire
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FormBuilderTextField(
                                name: 'email',
                                decoration: InputDecoration(
                                  labelText: AppConstants.emailLabel,
                                  hintText: AppConstants.emailHint,
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                    errorText: AppConstants.emailRequired,
                                  ),
                                  FormBuilderValidators.email(
                                    errorText: AppConstants.emailInvalid,
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 20),
                              FormBuilderTextField(
                                name: 'password',
                                decoration: InputDecoration(
                                  labelText: AppConstants.passwordLabel,
                                  hintText: AppConstants.passwordHint,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                obscureText: true,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                    errorText: AppConstants.passwordRequired,
                                  ),
                                  FormBuilderValidators.minLength(
                                    6,
                                    errorText: AppConstants.passwordTooShort,
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 32),
                              
                              // Boutons
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton(
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
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: state is AuthLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  AppConstants.loginButton,
                                                  style: theme.textTheme.titleLarge?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () => context.go('/auth/signup'),
                                        child: Text(
                                          AppConstants.signupLink,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: theme.colorScheme.secondary,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
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
        ),
      ),
    );
  }
}
