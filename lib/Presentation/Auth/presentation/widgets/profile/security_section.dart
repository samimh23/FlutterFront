import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/data/models/user.dart';

class SecuritySection extends StatelessWidget {
  final User user;
  final VoidCallback onTwoFactorTap;
  final VoidCallback onChangePasswordTap;

  const SecuritySection({
    Key? key,
    required this.user,
    required this.onTwoFactorTap,
    required this.onChangePasswordTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = MediaQuery.of(context).size.width > 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isWeb ? 24.0 : 16.0,
            right: isWeb ? 24.0 : 16.0,
            bottom: isWeb ? 24.0 : 16.0,
            top: isWeb ? 32.0 : 24.0,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
                ),
                child: Icon(
                  Icons.security,
                  size: isWeb ? 28 : 24,
                  color: Colors.teal,
                ),
              ),
              SizedBox(width: isWeb ? 16 : 12),
              Text(
                'Security Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isWeb ? 24 : null,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: isWeb ? 4 : 2,
          margin: EdgeInsets.symmetric(
            horizontal: isWeb ? 16.0 : 8.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
              gradient: isWeb ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.teal.shade50,
                ],
              ) : null,
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
                  onTap: onTwoFactorTap,
                  isWeb: isWeb,
                ),
                Divider(
                  height: 1, 
                  indent: isWeb ? 80 : 56,
                  endIndent: isWeb ? 16 : 8,
                ),
                _buildSecurityTile(
                  icon: Icons.password,
                  title: 'Change Password',
                  subtitle: 'Update your password periodically',
                  iconColor: Colors.blue,
                  onTap: onChangePasswordTap,
                  isWeb: isWeb,
                ),
              ],
            ),
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
    required bool isWeb,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 24.0 : 16.0,
        vertical: isWeb ? 16.0 : 8.0,
      ),
      leading: Container(
        padding: EdgeInsets.all(isWeb ? 16.0 : 12.0),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          boxShadow: isWeb ? [
            BoxShadow(
              color: iconColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Icon(icon, color: iconColor, size: isWeb ? 32 : 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isWeb ? 20 : 16,
          color: Colors.grey.shade800,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: isWeb ? 8.0 : 4.0),
        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            color: Colors.grey.shade600,
          ),
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
        ),
        padding: EdgeInsets.all(isWeb ? 8.0 : 4.0),
        child: Icon(
          Icons.chevron_right,
          size: isWeb ? 28 : 24,
          color: iconColor.withOpacity(0.7),
        ),
      ),
      onTap: onTap,
    );
  }
}