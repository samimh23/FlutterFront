import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:local_auth/local_auth.dart';

class checkbiometrics{
  final  LocalAuthentication auth= LocalAuthentication();
  Future<void> _authenticate() async {
    await auth.authenticate(
      localizedReason:
      'Scan your fingerprint (or face or whatever) to authenticate',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
}
}
