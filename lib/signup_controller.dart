import 'package:flutter/material.dart';

class SignupController {
  final TextEditingController namectrl;
  final TextEditingController emailctrl;
  final TextEditingController agectrl;
  final TextEditingController passwordctrl;
  final TextEditingController repasswordctrl;
  final TextEditingController cinctrl;
  String _errorMessage = '';

  SignupController({
    required this.namectrl,
    required this.emailctrl,
    required this.agectrl,
    required this.passwordctrl,
    required this.repasswordctrl,
    required this.cinctrl,
  });


  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatename(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name should not be empty';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name should not contain numbers or special characters';
    }
    return null;
  }

  String? validateage(String? age) {
    if (age == null || age.isEmpty) {
      return 'Age should not be empty';
    }
    if (!RegExp(r'^[1-9][0-9]?$').hasMatch(age)) {
      return 'Enter a valid age (1-99)';
    }
    return null;
  }


  String? validatecin(String? cin) {
    if (cin == null || cin.isEmpty) {
      return 'CIN should not be empty';
    }
    if (!RegExp(r'^[0-9]{8}$').hasMatch(cin)) {
      return 'CIN must be exactly 8 digits';
    }
    return null;
  }

  String? validatePassword(String password) {
    _errorMessage = '';

    if (password.length < 6) {
      _errorMessage += '• Password must be longer than 6 characters.\n';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += '• Uppercase letter is missing.\n';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += '• Lowercase letter is missing.\n';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += '• Digit is missing.\n';
    }
    if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += '• Special character is missing.\n';
    }

    return _errorMessage.isEmpty ? null : _errorMessage;
  }

  String? validatebothpasswords(String? password, String? reEnterPassword) {
    if (password != reEnterPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  void Signup(BuildContext context) {
    String? passwordError = validatebothpasswords(passwordctrl.text, repasswordctrl.text);

    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: Colors.red, // Red color for error
        ),
      );
      return; // Prevent further execution
    }

    // TODO: Implement signup logic (e.g., API call)
    print("Signing up...");
  }
}
