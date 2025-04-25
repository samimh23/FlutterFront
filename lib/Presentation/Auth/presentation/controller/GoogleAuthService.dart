import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Core/Utils/secure_storage.dart';
import '../../../../Core/network/apiconastant.dart';


class GoogleAuthService {
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleAuthUrl = '${ApiConstants.baseUrl}/users/google-redirect';

      if (kIsWeb) {
        // For web, just redirect the browser
        _launchUrl(Uri.parse(googleAuthUrl));
      } else {
        // For mobile, show a dialog informing the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('External Sign-In'),
            content: const Text(
                'You will be redirected to Google to sign in. After signing in, '
                    'you will be redirected back to the app.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _launchUrl(Uri.parse(googleAuthUrl));
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<void> signOut() async {
    await _secureStorageService.clearTokens();
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}