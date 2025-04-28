import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/presentation/pages/password_reset_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../Core/Utils/validators.dart';
import '../../../../responsive/responsive_layout.dart';
import '../controller/login_controller.dart';
import 'TwoFactorAuthScreen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveLayout.isMobile(context)
          ? AppBar(title: const Text('Login'))
          : null,
      body: SafeArea(
        child: ResponsiveLayout.builder(
          context: context,
          mobile: _MobileLayout(),
          tablet: _TabletLayout(),
          desktop: _DesktopLayout(),
        ),
      ),
    );
  }
}

// Mobile layout view
class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _LoginForm(),
          ],
        ),
      ),
    );
  }
}

// Tablet layout view
class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: ResponsiveLayout.getWidth(context) * 0.7,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sign In to Your Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Desktop layout view
class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side - Brand/Information panel
        Expanded(
          flex: 5,
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to\nHanouty',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sign in to access your account and continue shopping.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Add brand logo or illustration here
                  const Spacer(),
                  Row(
                    children: [
                      const Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right side - Login form
        Expanded(
          flex: 7,
          child: Center(
            child: Container(
              width: ResponsiveLayout.getWidth(context) * 0.35,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 40.0
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Form(
      key: _formKey,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              _buildTextField(
                controller: authProvider.emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: authProvider.status != AuthStatus.loading,
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildPasswordField(authProvider),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: authProvider.rememberMe,
                    onChanged: (value) {
                      authProvider.setRememberMe(value ?? false);
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const Text('Remember me'),
                  const Spacer(),
                  // Forgot Password Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordResetPage(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Error Message
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Login Button
              SizedBox(
                height: 50,
                width: isDesktop ? 300 : double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.status == AuthStatus.loading
                      ? null
                      : () => _handleLogin(context, authProvider),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: authProvider.status == AuthStatus.loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ADD THESE LINES - Start
              const SizedBox(height: 20),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 20),

              // Google Sign-In Button
              _buildGoogleSignInButton(authProvider),
              // ADD THESE LINES - End

              // Register Link (only for mobile and tablet)
              if (!isDesktop) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
  Future<void> _handleLogin(BuildContext context, AuthProvider authProvider) async {
    // --- 1. Start Login Process ---
    print("Login button pressed."); // DEBUG
    if (_formKey.currentState?.validate() ?? false) {
      print("Form is valid."); // DEBUG

      // Use ScaffoldMessenger captured before async gap
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        print("Calling authProvider.login()..."); // DEBUG
        // --- 2. Call Provider Login ---
        final success = await authProvider.login();
        print("authProvider.login() completed. Success: $success, Status: ${authProvider.status}, Error: ${authProvider.errorMessage}"); // DEBUG

        // --- 3. Handle Result (check mounted AFTER await) ---
        if (mounted) {
          if (success) {
            print("Login reported success."); // DEBUG
            // Check if 2FA is required
            if (authProvider.status == AuthStatus.requiresTwoFactor) {
              print("Navigating to 2FA screen."); // DEBUG
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TwoFactorAuthScreen(),
                ),
              );
            } else if (authProvider.status == AuthStatus.authenticated) {
              print("Navigating based on role."); // DEBUG
              // Normal authentication flow - navigate based on role
              authProvider.navigateBasedOnRole();
            } else {
              // This case might indicate an inconsistent state in AuthProvider
              print("Login success reported, but status is unexpected: ${authProvider.status}"); // DEBUG
              if (scaffoldMessenger.mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Login completed but state is unexpected. Please try again.')),
                );
              }
            }
          } else {
            // --- 4. Handle Failure ---
            print("Login reported failure."); // DEBUG
            // Login failed, rely on the provider's error message if available
            // If provider didn't set an error message, show a generic one.
            if (authProvider.errorMessage == null && scaffoldMessenger.mounted) {
              print("Provider error message is null, showing generic SnackBar."); // DEBUG
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Login failed. Please check your credentials.')),
              );
            } else {
              print("Provider error message: ${authProvider.errorMessage}"); // DEBUG
              // The Consumer widget should display the authProvider.errorMessage
            }
          }
        } else {
          print("Widget unmounted after login attempt."); // DEBUG
        }

      } catch (e, stackTrace) {
        // --- 5. Handle Exceptions ---
        print("Error during login process: $e"); // DEBUG
        print("Stack trace: $stackTrace"); // DEBUG
        if (mounted && scaffoldMessenger.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
          );
        }
        // Ensure loading state is reset in provider if an exception occurs
        // (AuthProvider's login method should ideally handle this internally in its own catch block)
        if (authProvider.status == AuthStatus.loading) {
          authProvider.resetStatusAfterError(); // Assuming such a method exists or implement one
        }
      }
    } else {
      print("Form is invalid."); // DEBUG
    }
  }
  // Helper method for creating text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: validator,
      enabled: enabled,
    );
  }
  Widget _buildGoogleSignInButton(AuthProvider authProvider) {
    return OutlinedButton.icon(
      onPressed: authProvider.status == AuthStatus.loading
          ? null
          : () => _handleGoogleSignIn(context, authProvider),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.white,
      ),
      icon: const Icon(
        Icons.g_mobiledata,
        size: 30,
        color: Colors.red,
      ),
      label: const Text(
        'Sign in with Google',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
  Future<void> _handleGoogleSignIn(BuildContext context, AuthProvider authProvider) async {
    authProvider.signInWithGoogle(context);
  }

  // Helper method for creating password field
  Widget _buildPasswordField(AuthProvider authProvider) {
    return TextFormField(
      controller: authProvider.passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: Validators.validatePassword,
      enabled: authProvider.status != AuthStatus.loading,
    );
  }
}