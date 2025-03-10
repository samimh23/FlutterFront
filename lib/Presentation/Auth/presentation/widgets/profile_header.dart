import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String profilepicture;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.email,
    required this.profilepicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          _buildProfileImage(context),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 16),
              const SizedBox(width: 8),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).primaryColorLight,
      child: _getProfileContent(context),
    );
  }

  Widget _getProfileContent(BuildContext context) {
    // Check if the URL is valid and not a placeholder
    if (profilepicture.isNotEmpty &&
        profilepicture != "http://example.com/profile.jpg" &&
        (profilepicture.startsWith('http://') || profilepicture.startsWith('https://'))) {
      // Use ClipOval to ensure the image is properly clipped in a circle
      return ClipOval(
        child: Image.network(
          profilepicture,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          // Add error handling for the image
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            return _getProfileInitial(context);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      return _getProfileInitial(context);
    }
  }

  Widget _getProfileInitial(BuildContext context) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 40,
        color: Colors.white,
      ),
    );
  }
}