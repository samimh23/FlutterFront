import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/profilep%5Erovider.dart';
import 'package:hanouty/Presentation/Auth/presentation/pages/SetupTwoFactorAuthScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../Subscription/presentation/manager/subsservice.dart';
import '../../data/models/user.dart';
import 'login_page.dart';

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

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await context.read<ProfileProvider>().uploadProfileImage(bytes);
      } else {
        final file = File(pickedFile.path);
        await context.read<ProfileProvider>().uploadProfileImage(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting or uploading image: $e')),
      );
    }
  }

  void _navigateToTwoFactorSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetupTwoFactorAuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == ProfileStatus.error) {
            return _buildErrorState(provider);
          }

          final user = provider.user;
          if (user == null) {
            return const Center(child: Text('No profile data available'));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(user, provider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.role == "Client") _buildUpgradeCard(),
                      const SizedBox(height: 24),
                      _buildSecuritySection(user, theme),
                      const SizedBox(height: 24),
                      _buildUserInfoSection(user, theme),
                      const SizedBox(height: 24),
                      _buildContactSection(user, theme),
                      const SizedBox(height: 32),
                      _buildDisconnectButton(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraButton() {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).primaryColor,
        child: IconButton(
          iconSize: 18,
          color: Colors.white,
          icon: const Icon(Icons.camera_alt),
          onPressed: _pickAndUploadImage,
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade700, Colors.orange.shade800],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showSubscriptionDialog,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Upgrade Your Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get access to premium features',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection(User user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Security',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSecurityTile(
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                subtitle: user.isTwoFactorEnabled == true
                    ? 'Enabled - Extra security active'
                    : 'Disabled - Enable for better security',
                iconColor: user.isTwoFactorEnabled == true
                    ? Colors.green
                    : Colors.orange,
                onTap: _navigateToTwoFactorSetup,
              ),
              const Divider(height: 1),
              _buildSecurityTile(
                icon: Icons.password,
                title: 'Change Password',
                subtitle: 'Update your password periodically',
                iconColor: Colors.blue,
                onTap: () {
                  // Navigate to change password screen
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildUserInfoSection(User user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Account Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.work,
                  iconColor: Colors.purple,
                  label: 'Role',
                  value: user.role,
                ),
                if (user.phonenumbers.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    label: 'Primary Phone',
                    value: user.phonenumbers.first.toString(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(User user, ThemeData theme) {
    if (user.phonenumbers.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Additional Contact Numbers',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: user.phonenumbers.length - 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final phoneNumber = user.phonenumbers[index + 1];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  phoneNumber.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(User user, ProfileProvider provider) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    provider.status == ProfileStatus.uploading
                        ? _buildUploadingAvatar(provider, user)
                        : _buildProfileAvatar(user),
                    if (provider.status != ProfileStatus.uploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCameraButton(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ProfileProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error: ${provider.errorMessage ?? "Unknown error"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadProfile(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              title: 'Merchant',
              description: 'Access bulk orders and connect with farmers',
              icon: Icons.store,
              color: Colors.blue,
              onTap: () {
                Navigator.of(context).pop();
                _initiateSubscription(SubscriptionType.merchant);
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
        backgroundImage: NetworkImage(user.profilepicture),
        onBackgroundImageError: (exception, stackTrace) {},
        child: user.name.isNotEmpty
            ? Text(
          user.name[0].toUpperCase(),
          style: const TextStyle(fontSize: 32, color: Colors.white),
        )
            : const Icon(Icons.person, size: 50, color: Colors.white),
        backgroundColor: Colors.grey,
      );
    } else {
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

  /// Disconnect Button
  /// Disconnect Button
  Widget _buildDisconnectButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          "Disconnect",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () async {
          // --- Show Confirmation Dialog ---
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog( // Use dialogContext
              title: const Text("Log out"),
              content: const Text("Are you sure you want to disconnect?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false), // Use dialogContext
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true), // Use dialogContext
                  child: const Text(
                    "Disconnect",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          // --- Proceed if confirmed ---
          // Check if the widget is still mounted before proceeding after the dialog
          if (shouldLogout == true && mounted) {
            // Capture the provider and navigator using the current context
            // before the async gap, in case the context becomes invalid.
            final profileProvider = context.read<ProfileProvider>();
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture ScaffoldMessenger

            try {
              // --- Call Logout Logic ---
              await profileProvider.logout(); // Clears state and tokens

              // --- Navigate AFTER logout ---
              // Check if the navigator is still mounted before navigation
              if (navigator.mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false, // Remove all previous routes
                );
              }
            } catch (e) {
              // --- Handle Logout Errors ---
              // Check if the scaffoldMessenger's context is still valid
              if (scaffoldMessenger.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error during logout: ${e.toString()}')),
                );
              }
              // Optionally print the error for debugging
              print('Logout error: $e');
            }
          }
        },
      ),
    );
  }
}