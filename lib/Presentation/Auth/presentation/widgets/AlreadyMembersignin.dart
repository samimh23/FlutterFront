import 'package:flutter/material.dart';

import '../pages/login_page.dart';

class AlreadyMemberSignin extends StatelessWidget {
  const AlreadyMemberSignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          const Text(
            'Already a member?',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(width: 8), // Add some space between text and button
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text(
              'Sign in',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
