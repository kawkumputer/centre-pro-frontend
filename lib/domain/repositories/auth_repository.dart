import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signup(String firstName, String lastName, String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
