import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../Core/Utils/validators.dart';
import '../../../../responsive/responsive_layout.dart';
import '../controller/register_controler.dart';


class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveLayout.isMobile(context)
          ? AppBar(title: const Text('Create Account'))
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
              'Join Hanouty',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _RegisterForm(),
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
                    'Create Your Hanouty Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _RegisterForm(),
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
                    'Create your account to get started with the complete shopping experience.',
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
                        'Already have an account?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        child: const Text(
                          'Sign In',
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
        // Right side - Registration form
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 80.0,
                  vertical: 40.0
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _RegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, bool isProfilePicture) async {
    final provider = Provider.of<RegisterProvider>(context, listen: false);

    final pickedFile = await _imagePicker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (isProfilePicture) {
        provider.setProfilePicture(pickedFile.path);
      } else {
        provider.setPatentImage(pickedFile.path);
      }
    }
  }

  void _addPhoneNumber(RegisterProvider provider) {
    final phoneText = _phoneController.text.trim();
    if (phoneText.isNotEmpty) {
      try {
        final phoneNumber = int.parse(phoneText);
        provider.addPhoneNumber(phoneNumber);
        _phoneController.clear();
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid phone number')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Form(
        key: _formKey,
        child: Consumer<RegisterProvider>(
        builder: (context, provider, _) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
      // Profile Picture
      Center(
      child: GestureDetector(
      onTap: () => _pickImage(context, true),
    child: CircleAvatar(
    radius: isMobile ? 50 : 60,
    backgroundImage: provider.profilePicturePath != null
    ? kIsWeb
    ? NetworkImage(provider.profilePicturePath!) as ImageProvider
        : FileImage(File(provider.profilePicturePath!))
        : null,
    child: provider.profilePicturePath == null
    ? Icon(Icons.person, size: isMobile ? 50 : 60)
        : null,
    ),
    ),
    ),
    const SizedBox(height: 8),
    const Center(
    child: Text("Tap to add profile picture",
    style: TextStyle(fontSize: 12, color: Colors.grey)),
    ),
    const SizedBox(height: 24),

    // Two-column layout for desktop
    if (isDesktop) ...[
    Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Left column
    Expanded(
    child: Column(
    children: [
    // Name Field
    _buildTextField(
    controller: provider.nameController,
    label: 'Full Name',
    hint: 'Enter your full name',
    icon: Icons.person_outline,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your name';
    }
    return null;
    },
    enabled: provider.status != RegisterStatus.loading,
    ),
    const SizedBox(height: 16),

    // Email Field
    _buildTextField(
    controller: provider.emailController,
    label: 'Email',
    hint: 'Enter your email',
    icon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: Validators.validateEmail,
    enabled: provider.status != RegisterStatus.loading,
    ),
    ],
    ),
    ),
    const SizedBox(width: 24),
    // Right column
    Expanded(
    child: Column(
    children: [
    // Password Field
    _buildPasswordField(provider),
    const SizedBox(height: 16),

    // CIN Field
    _buildTextField(
    controller: provider.cinController,
    label: 'CIN (Optional)',
    hint: 'Enter your CIN number',
    icon: Icons.badge_outlined,
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value != null && value.isNotEmpty) {
    try {
    int.parse(value);
    } catch (_) {
    return 'CIN must be a number';
    }
    }
    return null;
    },
    enabled: provider.status != RegisterStatus.loading,
    ),
    ],
    ),
    ),
    ],
    ),
    ] else ...[
    // Mobile & Tablet layout - single column
    _buildTextField(
    controller: provider.nameController,
    label: 'Full Name',
    hint: 'Enter your full name',
    icon: Icons.person_outline,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your name';
    }
    return null;
    },
    enabled: provider.status != RegisterStatus.loading,
    ),
    const SizedBox(height: 16),

    _buildTextField(
    controller: provider.emailController,
    label: 'Email',
    hint: 'Enter your email',
    icon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: Validators.validateEmail,
    enabled: provider.status != RegisterStatus.loading,
    ),
    const SizedBox(height: 16),

    _buildPasswordField(provider),
    const SizedBox(height: 16),

    _buildTextField(
    controller: provider.cinController,
    label: 'CIN (Optional)',
    hint: 'Enter your CIN number',
    icon: Icons.badge_outlined,
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value != null && value.isNotEmpty) {
    try {
    int.parse(value);
    } catch (_) {
    return 'CIN must be a number';
    }
    }
    return null;
    },
    enabled: provider.status != RegisterStatus.loading,
    ),
    ],

    const SizedBox(height: 24),

    // Phone Numbers Section
    _buildPhoneNumbersSection(provider),
    const SizedBox(height: 24),

    // Patent Image (Optional)
    _buildPatentImageSection(provider),
    const SizedBox(height: 24),

    // Error Message
    if (provider.errorMessage != null)
    Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
    provider.errorMessage!,
    style: const TextStyle(
    color: Colors.red,
    fontSize: 14,
    ),
    textAlign: TextAlign.center,
    ),
    ),

    // Register Button
    SizedBox(
    height: 50,
    width: isDesktop ? 300 : double.infinity,
    child: ElevatedButton(
    onPressed: provider.status == RegisterStatus.loading
    ? null
        : () => _handleRegister(context, provider),
    style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    foregroundColor: Colors.white,
    ),
    child: provider.status == RegisterStatus.loading
    ? const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
    strokeWidth: 2,
    color: Colors.white,
    ),
    )
        : const Text(
    'Create Account',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ),

    // Login Link (only for mobile and tablet)
    if (!isDesktop) ...[
    const SizedBox(height: 24),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    const Text('Already have an account?'),
    TextButton(
    onPressed: () {
          Navigator.of(context).pushNamed('/login');
          },
          child: const Text('Login'),
          ),
          ],
          ),
          ],

          ]);
        },
        ),
    );
  }

  Future<void> _handleRegister(BuildContext context, RegisterProvider provider) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if at least one phone number is added
      if (provider.phoneNumbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one phone number')),
        );
        return;
      }

      final success = await provider.register();
      if (success && mounted) {
        // Show success message and navigate to login page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please log in.')),
        );
        Navigator.of(context).pop(); // Return to login page
      }
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

  // Helper method for creating password field
  Widget _buildPasswordField(RegisterProvider provider) {
    return TextFormField(
      controller: provider.passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a password',
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
      enabled: provider.status != RegisterStatus.loading,
    );
  }

  // Helper method for phone numbers section
  Widget _buildPhoneNumbersSection(RegisterProvider provider) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Numbers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Phone Number Input Field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Add phone number',
                  prefixIcon: const Icon(Icons.phone),
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
                enabled: provider.status != RegisterStatus.loading,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: provider.status != RegisterStatus.loading
                  ? () => _addPhoneNumber(provider)
                  : null,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),

        // Phone Numbers List
        if (provider.phoneNumbers.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: provider.phoneNumbers.length > 2 ? 100 : 60,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.phoneNumbers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.phoneNumbers[index].toString(),
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: isMobile ? 20 : 24,
                            ),
                            onPressed: () {
                              provider.removePhoneNumber(provider.phoneNumbers[index]);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helper method for patent image section
  Widget _buildPatentImageSection(RegisterProvider provider) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patent Image (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(context, false),
          child: Container(
            height: 100,
            width: isDesktop ? 400 : double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: provider.patentImagePath != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.network(
                provider.patentImagePath!,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(provider.patentImagePath!),
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.upload_file, size: 30),
                SizedBox(height: 8),
                Text('Tap to upload patent image'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}