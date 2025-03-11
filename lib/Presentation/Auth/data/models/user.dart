class User {
  final String id;
  final String name;
  final String email;
  final List<dynamic> phonenumbers; // Changed from List<String>
  final String profilepicture;
  final String role;
  final bool isTwoFactorEnabled; // Added property for 2FA status

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phonenumbers,
    required this.profilepicture,
    required this.role,
    this.isTwoFactorEnabled = false, // Default to false if not provided
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle phonenumbers as dynamic list
    List<dynamic> phoneList = [];
    if (json['phonenumbers'] != null) {
      phoneList = json['phonenumbers'] is List
          ? json['phonenumbers']
          : []; // Handle case where it might not be a list
    }

    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phonenumbers: phoneList,
      profilepicture: json['profilepicture'] ?? '',
      role: json['role'] ?? '',
      isTwoFactorEnabled: json['isTwoFactorEnabled'] ?? false, // Parse from JSON
    );
  }

  // Convenience getter to get phone numbers as strings for display
  List<String> getPhoneNumbersAsStrings() {
    return phonenumbers.map((phone) => phone.toString()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phonenumbers': phonenumbers,
      'profilepicture': profilepicture,
      'role': role,
      'isTwoFactorEnabled': isTwoFactorEnabled, // Include in JSON output
    };
  }

  // Create a copy of this User with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    List<dynamic>? phonenumbers,
    String? profilepicture,
    String? role,
    bool? isTwoFactorEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phonenumbers: phonenumbers ?? this.phonenumbers,
      profilepicture: profilepicture ?? this.profilepicture,
      role: role ?? this.role,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
    );
  }
}