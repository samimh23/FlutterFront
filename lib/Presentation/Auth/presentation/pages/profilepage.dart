import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../Subscription/presentation/manager/subsservice.dart';
import '../../data/models/user.dart';
import '../controller/profilep^rovider.dart';
import '../controller/profileservice.dart';
import '../../../../Core/Utils/uploadservice.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  bool _isCheckingPayment = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileProvider>().loadProfile());
    WidgetsBinding.instance.addObserver(this); // Add observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app returning from payment
    if (state == AppLifecycleState.resumed) {
      final provider = context.read<ProfileProvider>();
      if (provider.status == ProfileStatus.subscribing || _isCheckingPayment) {
        provider.clearSubscriptionState();
        provider.loadProfile();
        setState(() {
          _isCheckingPayment = false;
        });
      }
    }
  }

  // ... rest of your existing methods

  Future<void> _pickAndUploadImage() async {
    try {
      // Select image from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Resize to reasonable dimensions
        maxHeight: 800,
        imageQuality: 85, // Adjust quality to balance size and quality
      );

      if (pickedFile == null) return;

      // Handle image based on platform
      if (kIsWeb) {
        // For web
        final bytes = await pickedFile.readAsBytes();
        await context.read<ProfileProvider>().uploadProfileImage(bytes);
      } else {
        // For mobile
        final file = File(pickedFile.path);
        await context.read<ProfileProvider>().uploadProfileImage(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting or uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == ProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.errorMessage ?? "Unknown error"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = provider.user;
          if (user == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image with Upload Button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    provider.status == ProfileStatus.uploading
                        ? _buildUploadingAvatar(provider, user)
                        : _buildProfileAvatar(user),
                    if (provider.status != ProfileStatus.uploading)
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          iconSize: 18,
                          color: Colors.white,
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickAndUploadImage,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                if (user.role == "Client")
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Upgrade Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _showSubscriptionDialog,
                  ),
                // User Info
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Additional User Info
                _buildInfoCard('Role', user.role, Icons.work),
                _buildPhoneNumbersList(user),
              ],
            ),
          );
        },
      ),
    );
  }
  // Add this method to show the subscription options dialog
  void _showSubscriptionDialog() {
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
              title: 'Farmer',
              description: 'List your produce and connect with buyers',
              icon: Icons.agriculture,
              color: Colors.green,
              onTap: () {
                Navigator.of(context).pop();
                _initiateSubscription(SubscriptionType.farmer);
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
                _initiateSubscription(SubscriptionType.wholesaler);
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

  // Add this method to build each subscription option in the dialog
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

  // Add this method to handle subscription initiation
  void _initiateSubscription(SubscriptionType type) async {
    setState(() {
      _isCheckingPayment = true;
    });

    try {
      await context.read<ProfileProvider>().initiateSubscription(type);
    } catch (e) {
      setState(() {
        _isCheckingPayment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting subscription process: $e')),
      );
    }
  }

  Widget _buildProfileAvatar(User user) {
    if (user.profilepicture.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(
          user.profilepicture,
          // The error handler shouldn't return a widget


            // We can't return a widget from here, just handle the error
          
        ),
        // Instead, use a fallback child that will show if the image fails to load
        child: user.name.isNotEmpty
            ? Text(
          user.name[0].toUpperCase(),
          style: const TextStyle(fontSize: 32, color: Colors.white),
        )
            : const Icon(Icons.person, size: 50, color: Colors.white),
        backgroundColor: Colors.grey,
      );
    } else {
      // Fallback placeholder with first letter of name
      return CircleAvatar(
        radius: 50,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 32, color: Colors.white),
        ),
      );
    }
  }
  Widget _buildUploadingAvatar(ProfileProvider provider, User user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildProfileAvatar(user),
        CircularProgressIndicator(
          value: provider.uploadProgress,
          backgroundColor: Colors.white.withOpacity(0.5),
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumbersList(User user) {
    if (user.phonenumbers.isEmpty) {
      return _buildInfoCard('Phone', 'No phone numbers available', Icons.phone_missed);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 8),
                Text('Phone Numbers', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...List.generate(user.phonenumbers.length, (index) {
            return ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(user.phonenumbers[index].toString()),
            );
          }),
        ],
      ),
    );
  }
}