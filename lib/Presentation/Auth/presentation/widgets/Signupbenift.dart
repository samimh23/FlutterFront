import 'package:flutter/material.dart';

class SignupBenefits extends StatelessWidget {
  const SignupBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50, // Light background color
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Why Sign Up?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          BenefitItem(text: "Access exclusive content"),
          BenefitItem(text: "Track your Clients"),
          BenefitItem(text: "Personalized recommendations"),
          BenefitItem(text: "24/7 customer support"),
        ],
      ),
    );
  }
}

class BenefitItem extends StatelessWidget {
  final String text;
  const BenefitItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
