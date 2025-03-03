import 'package:flutter/material.dart';
import 'package:hanouty/Core/api/api_exceptions.dart';

import '../../domain/entities/user.dart';
import '../../domain/use_cases/register_use_case.dart';


enum RegisterStatus {
  initial,
  loading,
  success,
  error,
}

class RegisterProvider extends ChangeNotifier {
  final RegisterUseCase _registerUseCase;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cinController = TextEditingController();

  // Phone numbers list
  List<int> phoneNumbers = [];

  // Image paths
  String? profilePicturePath;
  String? patentImagePath;

  RegisterStatus _status = RegisterStatus.initial;
  String? _errorMessage;
  User? _registeredUser;

  // Getters
  RegisterStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get registeredUser => _registeredUser;

  RegisterProvider({
    required RegisterUseCase registerUseCase,
  }) : _registerUseCase = registerUseCase;

  // Add phone number to list
  void addPhoneNumber(int phoneNumber) {
    if (!phoneNumbers.contains(phoneNumber)) {
      phoneNumbers.add(phoneNumber);
      notifyListeners();
    }
  }

  // Remove phone number from list
  void removePhoneNumber(int phoneNumber) {
    phoneNumbers.remove(phoneNumber);
    notifyListeners();
  }

  // Set profile picture path (you'll need image picker implementation)
  void setProfilePicture(String path) {
    profilePicturePath = path;
    notifyListeners();
  }

  // Set patent image path (you'll need image picker implementation)
  void setPatentImage(String path) {
    patentImagePath = path;
    notifyListeners();
  }

  // Clean up controllers when no longer needed
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cinController.dispose();
    super.dispose();
  }

  Future<bool> register() async {
    // Get values from text controllers
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Parse CIN if provided
    int? cin;
    if (cinController.text.isNotEmpty) {
      try {
        cin = int.parse(cinController.text.trim());
      } catch (_) {
        _status = RegisterStatus.error;
        _errorMessage = 'CIN must be a number';
        notifyListeners();
        return false;
      }
    }

    // Validate input
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _status = RegisterStatus.error;
      _errorMessage = 'Name, email and password are required';
      notifyListeners();
      return false;
    }

    if (phoneNumbers.isEmpty) {
      _status = RegisterStatus.error;
      _errorMessage = 'At least one phone number is required';
      notifyListeners();
      return false;
    }

    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _registerUseCase.execute(
        name: name,
        email: email,
        phoneNumbers: phoneNumbers,
        password: password,
        cin: cin,
        profilePicture: profilePicturePath,
        patentImage: patentImagePath,
      );

      _registeredUser = user;
      _status = RegisterStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch(e) {
      _status = RegisterStatus.error;
      // Check for specific error types
      if (e is BadRequestException && e.message.contains('already exists')) {
        _errorMessage = 'User with this email already exists';
      } else {
        _errorMessage = e.message;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _status = RegisterStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }
}