import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hanouty/Presentation/Auth/data/models/user.dart';

class ContactSection extends StatelessWidget {
  final User user;

  const ContactSection({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = MediaQuery.of(context).size.width > 768;
    
    if (user.phonenumbers.length <= 1) return const SizedBox.shrink();

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
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
                ),
                child: Icon(
                  Icons.contact_phone,
                  size: isWeb ? 28 : 24,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(width: isWeb ? 16 : 12),
              Text(
                'Additional Contact Numbers',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isWeb ? 24 : null,
                  color: Colors.indigo,
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
                  Colors.indigo.shade50,
                ],
              ) : null,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: user.phonenumbers.length - 1,
              separatorBuilder: (context, index) => Divider(
                height: 1, 
                indent: isWeb ? 80 : 56,
                endIndent: isWeb ? 16 : 8,
              ),
              itemBuilder: (context, index) {
                final phoneNumber = user.phonenumbers[index + 1];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 24 : 16,
                    vertical: isWeb ? 16 : 8,
                  ),
                  leading: Container(
                    padding: EdgeInsets.all(isWeb ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: Colors.indigo,
                      size: isWeb ? 32 : 24,
                    ),
                  ),
                  title: Text(
                    phoneNumber.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isWeb ? 20 : 16,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.content_copy,
                        size: isWeb ? 24 : 18,
                        color: Colors.indigo.shade400,
                      ),
                      tooltip: 'Copy to clipboard',
                      onPressed: () {
                        // Copy to clipboard functionality
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}