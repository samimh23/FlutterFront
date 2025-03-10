import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Auth/presentation/controller/profilep^rovider.dart';


class SubscriptionStatusPage extends StatefulWidget {
  final String sessionId;

  const SubscriptionStatusPage({
    Key? key,
    required this.sessionId
  }) : super(key: key);

  @override
  _SubscriptionStatusPageState createState() => _SubscriptionStatusPageState();
}

class _SubscriptionStatusPageState extends State<SubscriptionStatusPage> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // You would need to implement this method in your SubscriptionService
      // final status = await context.read<SubscriptionService>().checkSessionStatus(widget.sessionId);

      // For now, we'll simulate a successful payment
      await Future.delayed(const Duration(seconds: 2));
      final isSuccess = true; // This would come from the API

      setState(() {
        _isLoading = false;
        _isSuccess = isSuccess;
        _errorMessage = isSuccess ? null : 'Payment was not successful';
      });

      // Refresh profile information to get updated role
      if (_isSuccess) {
        await context.read<ProfileProvider>().loadProfile();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildStatusContent(),
      ),
    );
  }

  Widget _buildStatusContent() {
    if (_isSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 72,
            ),
            const SizedBox(height: 24),
            const Text(
              'Subscription Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your account has been upgraded successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to profile page
                Navigator.of(context).popUntil(
                      (route) => route.settings.name == '/profile' || route.isFirst,
                );
              },
              child: const Text('Return to Profile'),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 72,
            ),
            const SizedBox(height: 24),
            const Text(
              'Subscription Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred with your subscription.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkSubscriptionStatus,
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Navigate back to profile page
                Navigator.of(context).popUntil(
                      (route) => route.settings.name == '/profile' || route.isFirst,
                );
              },
              child: const Text('Return to Profile'),
            ),
          ],
        ),
      );
    }
  }
}