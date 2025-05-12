import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';

import '../../../../Core/theme/AppColors.dart';

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
      elevation: 1, // Reduced elevation for subtlety
      shadowColor: ClientColors.primary.withOpacity(0.1), // Updated shadow color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ClientColors.primary.withOpacity(0.05), // Subtle border
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_page_outlined,
                  size: 20,
                  color: ClientColors.primary, // Updated icon color
                ),
                const SizedBox(width: 8),
                Text(
                  "Contact Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ClientColors.text, // Updated text color
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: "Phone",
              value: marketPhone,
              onTap: () {
                // Handle phone tap - could launch phone dialer
              },
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: marketEmail,
              onTap: () {
                // Handle email tap - could launch email app
              },
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.location_on_outlined,
              label: "Address",
              value: marketLocation,
              onTap: () {
                // Handle location tap - could open maps
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: ClientColors.primary, // Updated icon color
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ClientColors.textLight, // Updated label color
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ClientColors.text, // Updated text color
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: ClientColors.primary.withOpacity(0.5), // Updated icon color
            ),
          ],
        ),
      ),
    );
  }
}