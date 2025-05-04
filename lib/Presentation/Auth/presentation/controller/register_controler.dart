import 'package:flutter/material.dart';
import 'package:hanouty/Core/api/api_exceptions.dart'; // Assuming this path is correct

// Assuming these paths are correct
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
  // --- 1. Add Age Controller ---
  final TextEditingController ageController = TextEditingController();

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

  // Set profile picture path
  void setProfilePicture(String path) {
    profilePicturePath = path;
    notifyListeners();
  }

  // Set patent image path
  void setPatentImage(String path) {
    patentImagePath = path;
    notifyListeners();
  }

  // --- 2. Update dispose method ---
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cinController.dispose();
    ageController.dispose(); // Dispose the age controller
    super.dispose();
  }

  // --- 3. Update register method ---
  Future<bool> register() async {
    // Get values from text controllers
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final ageString = ageController.text.trim(); // Get age string

    // Parse CIN if provided
    int? cin;
    if (cinController.text.isNotEmpty) {
      try {
        cin = int.parse(cinController.text.trim());
      } catch (_) {
        _status = RegisterStatus.error;
        _errorMessage = 'CIN must be a valid number';
        notifyListeners();
        return false;
      }
    }

    // Parse Age
    int? age;
    if (ageString.isEmpty) {
      _status = RegisterStatus.error;
      _errorMessage = 'Age is required'; // Make age required
      notifyListeners();
      return false;
    }
    try {
      age = int.parse(ageString);
      if (age <= 0) { // Validate age is positive
        throw FormatException("Age must be positive");
      }
    } catch (_) {
      _status = RegisterStatus.error;
      _errorMessage = 'Age must be a valid positive number';
      notifyListeners();
      return false;
    }


    // Validate other required fields
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _status = RegisterStatus.error;
      _errorMessage = 'Name, email and password are required';
      notifyListeners();
      return false;
    }

    // Validate email format (optional but recommended)
    // if (!Validators.validateEmailBool(email)) { // Assuming you have a bool validator
    //   _status = RegisterStatus.error;
    //   _errorMessage = 'Invalid email format';
    //   notifyListeners();
    //   return false;
    // }

    if (phoneNumbers.isEmpty) {
      _status = RegisterStatus.error;
      _errorMessage = 'At least one phone number is required';
      notifyListeners();
      return false;
    }

    // --- Set loading state ---
    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // --- 4. Pass age to UseCase ---
      // IMPORTANT: Ensure your RegisterUseCase.execute method accepts 'age'
      final user = await _registerUseCase.execute(
        name: name,
        email: email,
        phoneNumbers: phoneNumbers,
        password: password,
        age: age, // Pass the parsed age
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
      if (e is BadRequestException && e.message.contains('already exists')) { // Be more specific if possible
        _errorMessage = 'User with this email already exists';
      } else {
        _errorMessage = e.message; // Use the message from the exception
      }
      notifyListeners();
      return false;
    } catch (e) {
      _status = RegisterStatus.error;
      _errorMessage = 'An unexpected error occurred: $e'; // Include error details for debugging
      notifyListeners();
      return false;
    } finally {
      // Ensure loading state is cleared if not success/error (though less likely here)
      if (_status == RegisterStatus.loading) {
        _status = RegisterStatus.initial; // Or error? Decide based on flow.
        notifyListeners();
      }
    }
  }
}