import 'package:flutter/foundation.dart'; // Keep if needed

// Assuming Role and RoleExtension are defined correctly elsewhere
import '../../../../Core/Enums/role_enum.dart';

class User {
  final String? id;
  final String? name; // Represents 'firstName' potentially
  final String? lastName;
  final String email;
  final List<int>? phoneNumbers;
  final int? cin;
  final int? age;
  final DateTime? createdAt;
  final String? profilePicture;
  final String provider;
  final Role role;
  final String? headerAccountId; // <-- 1. Add Hedera Account ID field
  final String? privateKey;      // <-- 2. Add Hedera Private Key field
  // You might also want to add 'gender' and 'patentImage' if needed later

  User({
    this.id,
    this.name,
    this.lastName,
    required this.email,
    this.phoneNumbers,
    this.cin,
    this.age,
    this.createdAt,
    this.profilePicture,
    this.provider = 'local', // Default provider
    this.role = Role.Client, // Default role
    this.headerAccountId,    // <-- 3. Add Hedera Account ID to constructor
    this.privateKey,         // <-- 4. Add Hedera Private Key to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return User(
      // Use 'as String?' for type safety if unsure about backend types
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? json['firstName'] as String?, // Allow 'firstName'
      lastName: json['lastName'] as String?,
      email: json['email'] as String, // Assume email is always present
      phoneNumbers: json['phonenumbers'] != null && json['phonenumbers'] is List
          ? List<int>.from((json['phonenumbers'] as List)
          .map((e) => tryParseInt(e))
          .where((e) => e != null)
          .cast<int>())
          : null,
      cin: tryParseInt(json['cin']),
      age: tryParseInt(json['age']),
      createdAt: json['createdat'] != null && json['createdat'] is String
          ? DateTime.tryParse(json['createdat'] as String)
          : null,
      profilePicture: json['profilepicture'] as String?,
      provider: json['provider'] as String? ?? 'local',
      role: json['role'] != null && json['role'] is String
          ? RoleExtension.fromString(json['role'] as String)
          : Role.Client,
      headerAccountId: json['headerAccountId'] as String?, // <-- 5. Parse Hedera Account ID
      privateKey: json['privateKey'] as String?,          // <-- 6. Parse Hedera Private Key
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'role': role.value, // Assuming role.value gives the string representation
      'provider': provider,
    };

    // Conditionally add fields only if they are not null
    if (id != null) data['id'] = id; // Or '_id'
    if (name != null) data['name'] = name; // Or 'firstName'
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumbers != null && phoneNumbers!.isNotEmpty) data['phonenumbers'] = phoneNumbers;
    if (cin != null) data['cin'] = cin;
    if (age != null) data['age'] = age;
    if (createdAt != null) data['createdat'] = createdAt!.toIso8601String();
    if (profilePicture != null) data['profilepicture'] = profilePicture;
    // if (headerAccountId != null) data['headerAccountId'] = headerAccountId; // <-- 7. DO NOT add privateKey. Add headerAccountId ONLY if needed by an API.

    return data;
  }

  // Create a copy with optional updated fields
  User copyWith({
    String? id,
    String? name,
    String? lastName,
    String? email,
    List<int>? phoneNumbers,
    int? cin,
    int? age,
    DateTime? createdAt,
    String? profilePicture,
    String? provider,
    Role? role,
    String? headerAccountId, // <-- 8. Add Hedera Account ID parameter
    String? privateKey,      // <-- 9. Add Hedera Private Key parameter
    // Add 'gender' and 'patentImage' if needed
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      cin: cin ?? this.cin,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      profilePicture: profilePicture ?? this.profilePicture,
      provider: provider ?? this.provider,
      role: role ?? this.role,
      headerAccountId: headerAccountId ?? this.headerAccountId, // <-- 10. Use Hedera Account ID parameter
      privateKey: privateKey ?? this.privateKey,                // <-- 11. Use Hedera Private Key parameter
      // Add 'gender' and 'patentImage' assignment here
    );
  }

  // Optional: Override toString for better debugging
  @override
  String toString() {
    // Avoid printing privateKey in logs
    return 'User(id: $id, name: $name, email: $email, age: $age, role: $role, headerAccountId: $headerAccountId)';
  }

  // Optional: Override == and hashCode for comparisons
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id && // Often ID is sufficient for equality
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode; // Base hash on ID and email
}