import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/data/models/user.dart';

class UserInfoSection extends StatelessWidget {
  final User user;

  const UserInfoSection({
    Key? key,
    required this.user,
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
            top: isWeb ? 16.0 : 8.0,
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isWeb ? 28 : 24,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Account Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isWeb ? 24 : null,
                  color: theme.primaryColor,
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
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.email,
                  iconColor: Colors.blue,
                  label: 'Email',
                  value: user.email,
                  isWeb: isWeb,
                ),
                
                Divider(height: isWeb ? 40 : 32),
                
                _buildInfoRow(
                  icon: Icons.work,
                  iconColor: Colors.purple,
                  label: 'Role',
                  value: user.role,
                  isWeb: isWeb,
                ),
                
                if (user.phonenumbers.isNotEmpty) ...[
                  Divider(height: isWeb ? 40 : 32),
                  _buildInfoRow(
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    label: 'Primary Phone',
                    value: user.phonenumbers.first.toString(),
                    isWeb: isWeb,
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
    required bool isWeb,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isWeb ? 16 : 12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
          ),
          child: Icon(
            icon, 
            color: iconColor,
            size: isWeb ? 32 : 24,
          ),
        ),
        SizedBox(width: isWeb ? 24 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isWeb ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isWeb ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}