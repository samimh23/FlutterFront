import 'package:flutter/material.dart';

import '../../../../Subscription/presentation/manager/subsservice.dart';

class SubscriptionDialog extends StatelessWidget {
  final Function(SubscriptionType) onSubscribe;

  const SubscriptionDialog({
    Key? key,
    required this.onSubscribe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Subscription Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select the role you want to subscribe to:'),
          const SizedBox(height: 16),
          _buildSubscriptionOption(
            title: 'Farmer',
            description: 'List your produce and connect with buyers',
            icon: Icons.agriculture,
            color: Colors.green,
            onTap: () {
              Navigator.of(context).pop();
              onSubscribe(SubscriptionType.farmer);
            },
          ),
          const SizedBox(height: 12),
          _buildSubscriptionOption(
            title: 'Wholesaler',
            description: 'Access bulk orders and connect with farmers',
            icon: Icons.store,
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).pop();
              onSubscribe(SubscriptionType.merchant);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}