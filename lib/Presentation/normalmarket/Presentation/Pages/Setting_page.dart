import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Import your Dashboard screen
import '../../../AIForBussines/DashboardScreen.dart';
import '../../../../Core/theme/AppColors.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.secondary,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline,
                color: colorScheme.secondary,
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
            _buildProfileSection(colorScheme, textTheme),
            const SizedBox(height: 24),

            // Analytics Preview Card
            _buildAnalyticsPreviewCard(colorScheme, textTheme),
            const SizedBox(height: 24),

            _buildSectionHeader('Account Settings', Icons.account_circle_outlined, colorScheme, textTheme),
            _buildSettingsCard([
              _buildNavigationItem(
                'Personal Information',
                Icons.person_outline,
                colorScheme,
                textTheme,
                onTap: () => _navigateToPersonalInfo(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Wallet & Payment Methods',
                Icons.account_balance_wallet_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToPaymentMethods(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Security Settings',
                Icons.security_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToSecurity(),
                showBadge: true,
              ),
            ]),

            const SizedBox(height: 24),

            // Add Analytics & Reports Section
            _buildSectionHeader('Analytics & Reports', Icons.analytics_outlined, colorScheme, textTheme),
            _buildSettingsCard([
              _buildNavigationItem(
                'AI Sales Dashboard',
                Icons.dashboard_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToAIDashboard(),
                showBadge: true,
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Market Performance',
                Icons.show_chart,
                colorScheme,
                textTheme,
                onTap: () => _navigateToMarketPerformance(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Customer Insights',
                Icons.people_outline,
                colorScheme,
                textTheme,
                onTap: () => _navigateToCustomerInsights(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Report Settings',
                Icons.settings_applications_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToReportSettings(),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('App Settings', Icons.settings_outlined, colorScheme, textTheme),
            _buildSettingsCard([
              _buildSwitchItem(
                'Notifications',
                Icons.notifications_outlined,
                colorScheme,
                textTheme,
                _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                subtitle: 'Receive updates about your markets and products',
              ),
              const Divider(height: 1),
              _buildExpandableItem(
                'Language',
                Icons.language_outlined,
                colorScheme,
                textTheme,
                _selectedLanguage,
                _languages,
                    (value) => setState(() => _selectedLanguage = value),
              ),
              const Divider(height: 1),
              _buildExpandableItem(
                'Currency',
                Icons.currency_exchange_outlined,
                colorScheme,
                textTheme,
                _selectedCurrency,
                _currencies,
                    (value) => setState(() => _selectedCurrency = value),
              ),
              const Divider(height: 1),
              _buildSwitchItem(
                'Use System Theme',
                Icons.brightness_auto_outlined,
                colorScheme,
                textTheme,
                _useSystemTheme,
                    (value) {
                  setState(() {
                    _useSystemTheme = value;
                    if (value) {
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
                  colorScheme,
                  textTheme,
                  _darkModeEnabled,
                      (value) => setState(() => _darkModeEnabled = value),
                ),
              ],
              const Divider(height: 1),
              _buildSwitchItem(
                'Biometric Authentication',
                Icons.fingerprint,
                colorScheme,
                textTheme,
                _useBiometrics,
                    (value) => setState(() => _useBiometrics = value),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('App Information', Icons.info_outline, colorScheme, textTheme),
            _buildSettingsCard([
              _buildNavigationItem(
                'About Hanouty',
                Icons.store_outlined,
                colorScheme,
                textTheme,
                onTap: () => _showAboutDialog(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Terms & Conditions',
                Icons.description_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToTerms(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToPrivacyPolicy(),
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Contact Support',
                Icons.support_agent_outlined,
                colorScheme,
                textTheme,
                onTap: () => _navigateToSupport(),
              ),
            ]),

            const SizedBox(height: 24),

            _buildLogoutButton(colorScheme, textTheme),

            const SizedBox(height: 40),

            Center(
              child: Text(
                'App Version: 1.0.5',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildProfileSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                    color: colorScheme.secondary,
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
                    Text(
                      'Aladin Ayari',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'aladin.ayari@example.com',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
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
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary,
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
                    color: colorScheme.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.secondary,
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
              color: colorScheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withOpacity(0.15),
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
                    colorScheme.secondary,
                    textTheme,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: colorScheme.secondary.withOpacity(0.15),
                ),
                Expanded(
                  child: _buildProfileStat(
                    'Products',
                    '12',
                    Icons.inventory_2_outlined,
                    Colors.blue,
                    textTheme,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: colorScheme.secondary.withOpacity(0.15),
                ),
                Expanded(
                  child: _buildProfileStat(
                    'NFTs',
                    '3',
                    Icons.token_outlined,
                    colorScheme.primary,
                    textTheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Analytics Preview Card
  Widget _buildAnalyticsPreviewCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Analytics',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToAIDashboard(),
                child: Text(
                  'View Dashboard',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildAnalyticItem(
                  'This Month',
                  '₮3,456',
                  Icons.trending_up,
                  colorScheme.secondary,
                  '+12%',
                  textTheme
              ),
              const SizedBox(width: 16),
              _buildAnalyticItem(
                  'Orders',
                  '48',
                  Icons.shopping_bag_outlined,
                  Colors.blue,
                  '+8%',
                  textTheme
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 40,
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to view full analytics',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToAIDashboard(),
            icon: Icon(Icons.analytics_outlined, color: colorScheme.onPrimary),
            label: Text(
              'Open AI Dashboard',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value, IconData icon, Color color, String trend, TextTheme textTheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              trend,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.primary, // Show green for positive trends
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon, Color color, TextTheme textTheme) {
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
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      ColorScheme colorScheme,
      TextTheme textTheme,
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
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: subtitle != null
            ? Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }

  Widget _buildNavigationItem(
      String title,
      IconData icon,
      ColorScheme colorScheme,
      TextTheme textTheme,
      {required VoidCallback onTap, bool showBadge = false}
      ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: colorScheme.secondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'NEW',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.5),
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
      ColorScheme colorScheme,
      TextTheme textTheme,
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
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          currentValue,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 13,
            color: colorScheme.secondary,
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
                        style: textTheme.bodyLarge?.copyWith(
                          color: option == currentValue
                              ? colorScheme.secondary
                              : colorScheme.onSurface.withOpacity(0.65),
                          fontWeight: option == currentValue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (option == currentValue)
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.secondary,
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

  Widget _buildLogoutButton(ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(colorScheme, textTheme),
      icon: Icon(Icons.logout, color: Colors.redAccent),
      label: Text(
        'Log Out',
        style: textTheme.labelLarge?.copyWith(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showLogoutDialog(ColorScheme colorScheme, TextTheme textTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
            const SizedBox(width: 10),
            Text('Log Out', style: textTheme.titleMedium),
          ],
        ),
        content: Text('Are you sure you want to log out?', style: textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary)),
                  backgroundColor: colorScheme.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text('Log Out', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 10),
            Text('Help & Support', style: textTheme.titleMedium),
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
            child: Text(
              'Close',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSupport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
            ),
            child: Text('Contact Support', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.store,
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 10),
            Text('About Hanouty', style: textTheme.titleMedium),
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
            Text(
              'Hanouty',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.5',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hanouty is a marketplace for tokenized produce, connecting farmers directly with consumers through blockchain technology.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 Hanouty Inc. All rights reserved.',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods (unchanged)
  void _navigateToEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToPersonalInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Personal Information'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToPaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Payment Methods'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToSecurity() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Security Settings'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  // Analytics navigation methods
  void _navigateToAIDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _navigateToMarketPerformance() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Market Performance'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToCustomerInsights() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Customer Insights'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToReportSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Report Settings'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Terms & Conditions'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Privacy Policy'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _navigateToSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigate to Support'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}