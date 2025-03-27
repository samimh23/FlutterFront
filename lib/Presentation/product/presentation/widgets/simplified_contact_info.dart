import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';

class SimplifiedContactInfo extends StatelessWidget {
  final String marketName;
  final String marketLocation;
  final String marketPhone;
  final String marketEmail;

  const SimplifiedContactInfo({
    super.key,
    required this.marketName,
    required this.marketLocation,
    required this.marketPhone,
    required this.marketEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contact Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  marketPhone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  marketEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Row(
              children: [
                const Icon(Icons.location_city, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  marketLocation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}