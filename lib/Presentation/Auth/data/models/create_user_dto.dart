import 'package:flutter/foundation.dart';
import '../../../../Core/Enums/role_enum.dart';

class CreateUserDto {
  final String name;
  final String email;
  final List<int> phoneNumbers;
  final String password;
  final int? cin;
  final String? profilePicture;
  final String? patentImage;

  CreateUserDto({
    required this.name,
    required this.email,
    required this.phoneNumbers,
    required this.password,
    this.cin,
    this.profilePicture,
    this.patentImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phonenumbers': phoneNumbers,
      'password': password,
    };

    if (cin != null) data['cin'] = cin;
    if (profilePicture != null) data['profilepicture'] = profilePicture;
    if (patentImage != null) data['patentImage'] = patentImage;

    return data;
  }
}