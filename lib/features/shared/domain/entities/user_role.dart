enum UserRole {
  admin,
  professor,
  student,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.professor:
        return 'professor';
      case UserRole.student:
        return 'student';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.student,
    );
  }
}
