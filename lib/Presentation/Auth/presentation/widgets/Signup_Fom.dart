import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/login_controller.dart';
import 'package:hanouty/signup_controller.dart';

import 'Signup_with_google.dart';
import 'customtextFieald.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SignupController _signupController;

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      _signupController.Signup(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _signupController = SignupController(
      namectrl: TextEditingController(),
      emailctrl: TextEditingController(),
      agectrl: TextEditingController(),
      passwordctrl: TextEditingController(),
      repasswordctrl: TextEditingController(),
      cinctrl: TextEditingController(),
    );
  }

  @override
  void dispose() {
    _signupController.namectrl.dispose();
    _signupController.emailctrl.dispose();
    _signupController.agectrl.dispose();
    _signupController.passwordctrl.dispose();
    _signupController.repasswordctrl.dispose();
    _signupController.cinctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Logo (Placeholder)
              const Icon(Icons.auto_awesome, size: 50),
              const SizedBox(height: 20),
              // 🔹 Title & Subtitle
              const Text(
                "Welcome To Hanouty!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Please enter your details",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              CustomTextField(
                label: "Email",
                hintText: "Enter your email",
                controller: _signupController.emailctrl,
                isPassword: false,
                validator: _signupController.validateEmail,
              ),
              CustomTextField(
                label: "Name",
                hintText: "Enter your name",
                controller: _signupController.namectrl,
                isPassword: false,
                validator: _signupController.validatename,
              ),
              CustomTextField(
                label: "Age",
                hintText: "Enter your age",
                controller: _signupController.agectrl,
                isPassword: false,
                validator: _signupController.validateage,
              ),
              CustomTextField(
                label: "CIN",
                hintText: "Enter your CIN",
                controller: _signupController.cinctrl,
                isPassword: false,
                validator: (cin) => _signupController.validatecin(cin),
              ),
              CustomTextField(
                label: "Password",
                hintText: "Enter your password",
                controller: _signupController.passwordctrl,
                isPassword: true,
                validator: (password) => _signupController.validatePassword(password ?? ''),
              ),
              CustomTextField(
                label: "Re-Password",
                hintText: "Enter your password again",
                controller: _signupController.repasswordctrl,
                isPassword: true,
                validator: (rePassword) => _signupController.validatePassword(rePassword ?? ''),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignup,
                    child: const Text(
                      'Signup',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SignupWithGoogle(),
            ],
          ),
        ),
      ),
    );
  }
}