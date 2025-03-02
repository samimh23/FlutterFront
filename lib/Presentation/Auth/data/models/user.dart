class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phonenumber;
  final String? profilePicture;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phonenumber,
    this.profilePicture,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phonenumber: json['phonenumber'],
      profilePicture: json['profilepicture'] ?? json['picture'],
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phonenumber':phonenumber,
      'profilepicture': profilePicture,
      'role': role,
    };
  }
}