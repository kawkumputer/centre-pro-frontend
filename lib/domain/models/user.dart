import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  ADMIN,
  PROJECT_MANAGER,
  USER;

  String get displayName {
    switch (this) {
      case UserRole.ADMIN:
        return 'Administrateur';
      case UserRole.PROJECT_MANAGER:
        return 'Chef de projet';
      case UserRole.USER:
        return 'Utilisateur';
    }
  }
}

@JsonSerializable()
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      role.hashCode;

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  String get fullName => '$firstName $lastName';
}
