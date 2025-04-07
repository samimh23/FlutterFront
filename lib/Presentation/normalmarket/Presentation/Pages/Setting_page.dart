import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  // Currency options
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AED', 'SAR'];

  // Language options
  final List<String> _languages = ['English', 'Arabic', 'French', 'Spanish'];

  // System theme option
  bool _useSystemTheme = true;

  // Biometric authentication
  bool _useBiometrics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3), // Light cream background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            onPressed: () => _showHelpDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fruits_pattern_light.png'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),

            _buildSectionHeader('Account Settings', Icons.account_circle_outlined),
            _buildSettingsCard([
              _buildNavigationItem(
                'Personal Information',
                Icons.person_outline,
                onTap: () => _navigateToPersonalInfo(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Wallet & Payment Methods',
                Icons.account_balance_wallet_outlined,
                onTap: () => _navigateToPaymentMethods(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Security Settings',
                Icons.security_outlined,
                onTap: () => _navigateToSecurity(),
                showBadge: true,
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('App Settings', Icons.settings_outlined),
            _buildSettingsCard([
              _buildSwitchItem(
                'Notifications',
                Icons.notifications_outlined,
                _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                subtitle: 'Receive updates about your markets and products',
              ),
              const Divider(height: 1),
              _buildExpandableItem(
                'Language',
                Icons.language_outlined,
                _selectedLanguage,
                _languages,
                    (value) => setState(() => _selectedLanguage = value),
              ),
              const Divider(height: 1),
              _buildExpandableItem(
                'Currency',
                Icons.currency_exchange_outlined,
                _selectedCurrency,
                _currencies,
                    (value) => setState(() => _selectedCurrency = value),
              ),
              const Divider(height: 1),
              _buildSwitchItem(
                'Use System Theme',
                Icons.brightness_auto_outlined,
                _useSystemTheme,
                    (value) {
                  setState(() {
                    _useSystemTheme = value;
                    if (value) {
                      // Reset dark mode to system default if using system theme
                      _darkModeEnabled = false;
                    }
                  });
                },
              ),
              if (!_useSystemTheme) ...[
                const Divider(height: 1),
                _buildSwitchItem(
                  'Dark Mode',
                  Icons.dark_mode_outlined,
                  _darkModeEnabled,
                      (value) => setState(() => _darkModeEnabled = value),
                ),
              ],
              const Divider(height: 1),
              _buildSwitchItem(
                'Biometric Authentication',
                Icons.fingerprint,
                _useBiometrics,
                    (value) => setState(() => _useBiometrics = value),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('App Information', Icons.info_outline),
            _buildSettingsCard([
              _buildNavigationItem(
                'About Hanouty',
                Icons.store_outlined,
                onTap: () => _showAboutDialog(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Terms & Conditions',
                Icons.description_outlined,
                onTap: () => _navigateToTerms(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                onTap: () => _navigateToPrivacyPolicy(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Contact Support',
                Icons.support_agent_outlined,
                onTap: () => _navigateToSupport(),
              ),
            ]),

            const SizedBox(height: 24),

            _buildLogoutButton(),

            const SizedBox(height: 40),

            Center(
              child: Text(
                'App Version: 1.0.5',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aladin Ayari',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'aladin.ayari@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _navigateToEditProfile(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD8EBD8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildProfileStat(
                    'Your Markets',
                    '5',
                    Icons.storefront_outlined,
                    const Color(0xFF4CAF50),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: const Color(0xFFD8EBD8),
                ),
                Expanded(
                  child: _buildProfileStat(
                    'Products',
                    '12',
                    Icons.inventory_2_outlined,
                    const Color(0xFF2196F3),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: const Color(0xFFD8EBD8),
                ),
                Expanded(
                  child: _buildProfileStat(
                    'NFTs',
                    '3',
                    Icons.token_outlined,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchItem(
      String title,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      {String? subtitle}
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: SwitchListTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        subtitle: subtitle != null
            ? Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }

  Widget _buildNavigationItem(
      String title,
      IconData icon,
      {required VoidCallback onTap, bool showBadge = false}
      ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4CAF50),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF999999),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildExpandableItem(
      String title,
      IconData icon,
      String currentValue,
      List<String> options,
      Function(String) onChanged,
      ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4CAF50),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          currentValue,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4CAF50),
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 60, right: 16, bottom: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) =>
            InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: option == currentValue
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF555555),
                          fontWeight: option == currentValue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (option == currentValue)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
        ).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(),
      icon: const Icon(Icons.logout),
      label: const Text('Log Out'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
            SizedBox(width: 10),
            Text('Log Out'),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Color(0xFF4CAF50),
            ),
            SizedBox(width: 10),
            Text('Help & Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need assistance with your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• For account issues: Contact support@hanouty.com',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '• For market questions: Visit our FAQ section',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '• For blockchain support: Check our documentation',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to support page
              _navigateToSupport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.store,
              color: Color(0xFF4CAF50),
            ),
            SizedBox(width: 10),
            Text('About Hanouty'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hanouty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.5',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hanouty is a marketplace for tokenized produce, connecting farmers directly with consumers through blockchain technology.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Hanouty Inc. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Edit Profile'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _navigateToPersonalInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Personal Information'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _navigateToPaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Payment Methods'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _navigateToSecurity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Security Settings'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _navigateToTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Terms & Conditions'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Privacy Policy'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _navigateToSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Support'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}