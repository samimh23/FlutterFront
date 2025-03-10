class User {
  final String id;
  final String name;
  final String email;
  final List<dynamic> phonenumbers; // Changed from List<String>
  final String profilepicture;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phonenumbers,
    required this.profilepicture,
    required this.role,
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
    };
  }
}