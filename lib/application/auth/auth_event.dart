import '../../domain/models/user.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class SignupEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  SignupEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}
