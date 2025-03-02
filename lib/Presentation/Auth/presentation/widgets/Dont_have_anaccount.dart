import 'package:flutter/material.dart';

class DontHaveAnAccount extends StatelessWidget {
  final VoidCallback onSignupPressed;

  const DontHaveAnAccount({super.key, required this.onSignupPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content

        children: [
          const Text(
            "Still don't have an account?",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSignupPressed,
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
