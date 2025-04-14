import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Auth/presentation/controller/profilep^rovider.dart';
import '../manager/subsservice.dart';


class UpgradeAccountButton extends StatelessWidget {
  const UpgradeAccountButton({Key? key}) : super(key: key);

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Subscription Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select the role you want to subscribe to:'),
            const SizedBox(height: 16),
            _buildSubscriptionOption(
              context: context,
              title: 'Farmer',
              description: 'List your produce and connect with buyers',
              icon: Icons.agriculture,
              color: Colors.green,
              onTap: () {
                Navigator.of(context).pop();
                _initiateSubscription(context, SubscriptionType.farmer);
              },
            ),
            const SizedBox(height: 12),
            _buildSubscriptionOption(
              context: context,
              title: 'Merchant',
              description: 'Access bulk orders and connect with farmers',
              icon: Icons.store,
              color: Colors.blue,
              onTap: () {
                Navigator.of(context).pop();
                _initiateSubscription(context, SubscriptionType.merchant);
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
      ),
    );
  }

  Widget _buildSubscriptionOption({
    required BuildContext context,
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

  void _initiateSubscription(BuildContext context, SubscriptionType type) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.initiateSubscription(type);

      // If we have a URL to launch, open it
      final url = provider.subscriptionUrl;
      if (url != null && url.isNotEmpty) {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw Exception('Could not launch $url');
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error starting subscription: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.upgrade),
      label: const Text('Upgrade Account'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () => _showSubscriptionDialog(context),
    );
  }
}