import 'package:flutter/foundation.dart';

import '../../../../Core/Enums/role_enum.dart';

class User {
  final String? id;
  final String? name;
  final String? lastName;
  final String email;
  final List<int>? phoneNumbers;
  final int? cin;
  final DateTime? createdAt;
  final String? profilePicture;
  final String provider;
  final Role role;

  User({
    this.id,
    this.name,
    this.lastName,
    required this.email,
    this.phoneNumbers,
    this.cin,
    this.createdAt,
    this.profilePicture,
    this.provider = 'local',
    this.role = Role.Client,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumbers: json['phonenumbers'] != null
          ? List<int>.from(json['phonenumbers'])
          : null,
      cin: json['cin'],
      createdAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : null,
      profilePicture: json['profilepicture'],
      provider: json['provider'] ?? 'local',
      role: json['role'] != null
          ? RoleExtension.fromString(json['role'])
          : Role.Client,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'role': role.value,
      'provider': provider,
    };

    if (id != null) data['id'] = id;
    if (name != null) data['firstName'] = name;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumbers != null) data['phonenumbers'] = phoneNumbers;
    if (cin != null) data['cin'] = cin;
    if (createdAt != null) data['createdat'] = createdAt!.toIso8601String();
    if (profilePicture != null) data['profilepicture'] = profilePicture;

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
    DateTime? createdAt,
    String? profilePicture,
    String? provider,
    Role? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      cin: cin ?? this.cin,
      createdAt: createdAt ?? this.createdAt,
      profilePicture: profilePicture ?? this.profilePicture,
      provider: provider ?? this.provider,
      role: role ?? this.role,
    );
  }
}