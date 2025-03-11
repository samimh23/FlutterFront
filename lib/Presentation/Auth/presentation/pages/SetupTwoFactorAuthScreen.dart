import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controller/login_controller.dart';
import 'LoadingOverlay.dart';

class SetupTwoFactorAuthScreen extends StatefulWidget {
  const SetupTwoFactorAuthScreen({Key? key}) : super(key: key);

  @override
  _SetupTwoFactorAuthScreenState createState() => _SetupTwoFactorAuthScreenState();
}

class _SetupTwoFactorAuthScreenState extends State<SetupTwoFactorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _twoFactorCodeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = true;
  bool _isVerifying = false;
  Map<String, dynamic>? _secretData;

  @override
  void initState() {
    super.initState();
    _generateSecret();
  }

  Future<void> _generateSecret() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final secretData = await authProvider.generateTwoFactorSecret();

      setState(() {
        _secretData = secretData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate 2FA secret: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _enableTwoFactor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerifying = true;
        _errorMessage = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.enableTwoFactor(_twoFactorCodeController.text);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Two-factor authentication enabled successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to enable two-factor authentication. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Two-Factor Authentication'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enhance Your Account Security',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  '1. Scan the QR code with an authenticator app like Google Authenticator, Microsoft Authenticator, or Authy.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  '2. Enter the 6-digit verification code from the app below.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                if (_secretData != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _secretData!.containsKey('qrCodeDataUrl')
                          ? Image.memory(
                        base64Decode(_secretData!['qrCodeDataUrl'].split(',')[1]),
                        height: 200,
                        width: 200,
                      )
                          : QrImageView(
                        data: _secretData!['otpAuthUrl'] ?? '',
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_secretData != null && _secretData!.containsKey('secret'))
                  Column(
                    children: [
                      const Text(
                        'If you cannot scan the QR code, enter this secret key manually:',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            _secretData!['secret'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _secretData!['secret']));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Secret key copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _twoFactorCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                          hintText: 'Enter 6-digit code',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the verification code';
                          }
                          if (value.length != 6 || int.tryParse(value) == null) {
                            return 'Code must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _enableTwoFactor,
                          child: _isVerifying
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Enable Two-Factor Authentication',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Important: Store your backup codes in a safe place. If you lose access to your authenticator app, you will need these codes to regain access to your account.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _twoFactorCodeController.dispose();
    super.dispose();
  }
}