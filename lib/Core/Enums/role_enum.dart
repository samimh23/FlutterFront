enum Role {
  Admin,
  Client,
  Deliverer,
  Shop
  // Add other roles as needed
}

// Extension to convert enum to string and vice versa
extension RoleExtension on Role {
  String get value {
    return this.toString().split('.').last;
  }

  static Role fromString(String value) {
    return Role.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => Role.Client, // Default role
    );
  }
}