enum UserRole {
  ADMIN,
  PROJECT_MANAGER,
  USER
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: _parseRole(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.toString().split('.').last,
    };
  }

  static UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'PROJECT_MANAGER':
        return UserRole.PROJECT_MANAGER;
      default:
        return UserRole.USER;
    }
  }

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, email: $email, role: $role}';
  }
}
