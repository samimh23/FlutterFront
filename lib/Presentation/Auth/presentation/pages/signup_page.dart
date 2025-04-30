import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Assuming these imports exist and are correct
import '../../../../Core/Utils/validators.dart';
import '../../../../responsive/responsive_layout.dart';
import '../controller/register_controler.dart'; // Make sure RegisterProvider is defined here


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
    // Remember to dispose ageController in your RegisterProvider
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, bool isProfilePicture) async {
    final provider = Provider.of<RegisterProvider>(context, listen: false);

    // Prevent picking if loading
    if (provider.status == RegisterStatus.loading) return;

    final pickedFile = await _imagePicker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.gallery,
      // Optional: Add image quality constraints if needed
      // imageQuality: 50,
      // maxWidth: 800,
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
    // Prevent adding if loading
    if (provider.status == RegisterStatus.loading) return;

    final phoneText = _phoneController.text.trim();
    if (phoneText.isNotEmpty) {
      // Basic validation before parsing
      if (RegExp(r'^[0-9]+$').hasMatch(phoneText)) {
        try {
          final phoneNumber = int.parse(phoneText);
          provider.addPhoneNumber(phoneNumber);
          _phoneController.clear();
          // Hide keyboard
          FocusScope.of(context).unfocus();
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add phone number')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter only digits for phone number')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number cannot be empty')),
      );
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
          // **IMPORTANT**: This assumes `provider.ageController` exists in your RegisterProvider
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: provider.status != RegisterStatus.loading
                        ? () => _pickImage(context, true)
                        : null, // Disable tap when loading
                    child: CircleAvatar(
                      radius: isMobile ? 50 : 60,
                      backgroundColor: Colors.grey.shade200, // Background for placeholder
                      backgroundImage: provider.profilePicturePath != null
                          ? kIsWeb
                          ? NetworkImage(provider.profilePicturePath!) as ImageProvider
                          : FileImage(File(provider.profilePicturePath!))
                          : null,
                      child: provider.profilePicturePath == null
                          ? Icon(
                        Icons.person_add_alt_1, // Changed icon
                        size: isMobile ? 50 : 60,
                        color: Colors.grey.shade500, // Icon color
                      )
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
                      // --- Left column ---
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
                              validator: Validators.validateEmail, // Assuming this handles null/empty
                              enabled: provider.status != RegisterStatus.loading,
                            ),
                            const SizedBox(height: 16), // Spacing after Email

                            // *** Age Field (Desktop Left) ***
                            _buildTextField(
                              controller: provider.ageController, // Uses provider's controller
                              label: 'Age',
                              hint: 'Enter your age',
                              icon: Icons.cake_outlined, // Example icon
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your age';
                                }
                                final age = int.tryParse(value);
                                if (age == null) {
                                  return 'Please enter a valid number';
                                }
                                if (age <= 0) {
                                  return 'Age must be positive';
                                }
                                // Optional: Add an upper limit? e.g., if (age > 120) return 'Invalid age';
                                return null;
                              },
                              enabled: provider.status != RegisterStatus.loading,
                            ),
                            // *** End Age Field ***
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // --- Right column ---
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
                                // Allow empty value since it's optional
                                if (value != null && value.isNotEmpty) {
                                  // Validate only if not empty
                                  if (int.tryParse(value) == null) {
                                    return 'CIN must be a number';
                                  }
                                  // Optional: Add length validation if needed
                                  // if (value.length != 8) return 'CIN must be 8 digits';
                                }
                                return null; // No error if empty or valid number
                              },
                              enabled: provider.status != RegisterStatus.loading,
                            ),
                            const SizedBox(height: 16), // Spacing after CIN
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // --- Mobile & Tablet layout - single column ---
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
                    validator: Validators.validateEmail, // Assuming this handles null/empty
                    enabled: provider.status != RegisterStatus.loading,
                  ),
                  const SizedBox(height: 16),

                  _buildPasswordField(provider),
                  const SizedBox(height: 16),

                  // *** Age Field (Mobile/Tablet) ***
                  _buildTextField(
                    controller: provider.ageController, // Uses provider's controller
                    label: 'Age',
                    hint: 'Enter your age',
                    icon: Icons.cake_outlined, // Example icon
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value);
                      if (age == null) {
                        return 'Please enter a valid number';
                      }
                      if (age <= 0) {
                        return 'Age must be positive';
                      }
                      // Optional: Add an upper limit? e.g., if (age > 120) return 'Invalid age';
                      return null;
                    },
                    enabled: provider.status != RegisterStatus.loading,
                  ),
                  const SizedBox(height: 16),
                  // *** End Age Field ***

                  _buildTextField(
                    controller: provider.cinController,
                    label: 'CIN (Optional)',
                    hint: 'Enter your CIN number',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      // Allow empty value since it's optional
                      if (value != null && value.isNotEmpty) {
                        // Validate only if not empty
                        if (int.tryParse(value) == null) {
                          return 'CIN must be a number';
                        }
                        // Optional: Add length validation if needed
                        // if (value.length != 8) return 'CIN must be 8 digits';
                      }
                      return null; // No error if empty or valid number
                    },
                    enabled: provider.status != RegisterStatus.loading,
                  ),
                  const SizedBox(height: 16), // Added spacing after CIN
                ],

                // Keep the rest of the fields as they were
                const SizedBox(height: 8), // Adjusted spacing before Phone Numbers

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
                  // Center button on desktop, full width on mobile/tablet
                  width: isDesktop ? 300 : double.infinity,
                  child: Center( // Center the button itself if width is fixed (desktop)
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
                        minimumSize: Size(isDesktop ? 300 : double.infinity, 50), // Ensure button takes width
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
                ),

                // Login Link (only for mobile and tablet)
                if (!isDesktop) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: provider.status == RegisterStatus.loading ? null : () { // Disable when loading
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
    // Hide keyboard before validation/submission
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      // Check if at least one phone number is added
      if (provider.phoneNumbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one phone number')),
        );
        return; // Stop registration if no phone number
      }

      // Call the provider's register method
      // This method should now read the age from provider.ageController.text
      final success = await provider.register();

      // Check if the widget is still mounted before showing SnackBar or navigating
      if (mounted) {
        if (success) {
          // Show success message and navigate to login page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
          // Use pushReplacementNamed to prevent going back to register page
          Navigator.of(context).pushReplacementNamed('/login');
        }
        // No need for explicit 'else' here if the provider handles setting
        // the errorMessage which is displayed by the Consumer widget.
        // else {
        //   // Error message is already set by the provider and displayed by Consumer
        //   // Optionally show a generic snackbar if provider doesn't set errorMessage
        //   if (provider.errorMessage == null) {
        //      ScaffoldMessenger.of(context).showSnackBar(
        //        const SnackBar(content: Text('Registration failed. Please try again.')),
        //      );
        //   }
        // }
      }
    } else {
      // Form is not valid, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
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
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400), // Slightly darker border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5), // Thicker focus border
        ),
        errorBorder: OutlineInputBorder( // Style for error state
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder( // Style for error state when focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        filled: !enabled, // Optionally fill background when disabled
        fillColor: Colors.grey.shade100, // Fill color when disabled
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user interacts
      textInputAction: TextInputAction.next, // Move to next field on keyboard action
    );
  }

  // Helper method for creating password field
  Widget _buildPasswordField(RegisterProvider provider) {
    return TextFormField(
      controller: provider.passwordController,
      obscureText: _obscurePassword,
      enabled: provider.status != RegisterStatus.loading,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          // Disable suffix icon when loading
          onPressed: provider.status != RegisterStatus.loading ? () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          } : null,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        filled: provider.status == RegisterStatus.loading,
        fillColor: Colors.grey.shade100,
      ),
      validator: Validators.validatePassword, // Assuming this handles null/empty
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.done, // Last field, so 'done' action
      onFieldSubmitted: (_) { // Trigger registration when 'done' is pressed
        if (provider.status != RegisterStatus.loading) {
          _handleRegister(context, provider);
        }
      },
    );
  }

  // Helper method for phone numbers section
  Widget _buildPhoneNumbersSection(RegisterProvider provider) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Numbers (Required)', // Indicate requirement
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Phone Number Input Field
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: provider.status != RegisterStatus.loading,
                decoration: InputDecoration(
                  hintText: 'Add phone number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder( // Added error style
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder( // Added focused error style
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
                  ),
                  filled: provider.status == RegisterStatus.loading,
                  fillColor: Colors.grey.shade100,
                ),
                // Optional: Add validation directly to the input field
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Digits only';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done, // Action for this field
                onFieldSubmitted: (_) => _addPhoneNumber(provider), // Add number on submit
              ),
            ),
            const SizedBox(width: 8),
            // Use IconButton for adding for better alignment potentially
            Padding(
              padding: const EdgeInsets.only(top: 0), // Adjust padding if needed
              child: ElevatedButton(
                onPressed: provider.status != RegisterStatus.loading
                    ? () => _addPhoneNumber(provider)
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16), // Adjust padding if needed
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),

        // Phone Numbers List
        if (provider.phoneNumbers.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12), // Increased margin
            // Use constraints for flexible height
            constraints: const BoxConstraints(maxHeight: 120), // Max height for scroll
            decoration: BoxDecoration( // Add border to list container
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect( // Clip the list content
              borderRadius: BorderRadius.circular(8),
              child: Scrollbar( // Add scrollbar
                thumbVisibility: true, // Always show scrollbar thumb
                child: ListView.builder(
                  shrinkWrap: true, // Important for scrollable list in Column
                  itemCount: provider.phoneNumbers.length,
                  itemBuilder: (context, index) {
                    final number = provider.phoneNumbers[index];
                    return Material( // Added Material for InkWell effect
                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50, // Alternate row colors
                      child: InkWell( // Optional: Add InkWell for tap effect
                        onTap: () {}, // Placeholder action
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjusted padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row( // Group icon and text
                                children: [
                                  Icon(Icons.phone_android, size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    number.toString(),
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 15, // Slightly adjusted size
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline, // Changed icon
                                  color: Colors.red.shade400,
                                  size: isMobile ? 20 : 22, // Slightly adjusted size
                                ),
                                tooltip: 'Remove number', // Added tooltip
                                // Disable delete when loading
                                onPressed: provider.status != RegisterStatus.loading ? () {
                                  provider.removePhoneNumber(number);
                                } : null,
                              ),
                            ],
                          ),
                        ),
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
          // Disable tap when loading
          onTap: provider.status != RegisterStatus.loading ? () => _pickImage(context, false) : null,
          child: Container(
            height: 120, // Increased height
            width: double.infinity, // Take full width available
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100, // Background color
            ),
            child: provider.patentImagePath != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(7), // Clip inside border
              child: kIsWeb
                  ? Image.network(
                provider.patentImagePath!,
                fit: BoxFit.cover,
                // Add loading/error builders for network image
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                        : null,
                  ));
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey)),
              )
                  : Image.file(
                File(provider.patentImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            )
                : Center( // Centered placeholder
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey.shade600), // Changed icon
                  const SizedBox(height: 8),
                  Text('Tap to upload patent image', style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}