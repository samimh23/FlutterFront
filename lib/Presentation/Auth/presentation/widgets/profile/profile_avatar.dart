import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/data/models/user.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/profilep%5Erovider.dart';

class ProfileAvatar extends StatelessWidget {
  final User user;
  final ProfileProvider? provider;
  final VoidCallback onCameraPressed;

  const ProfileAvatar({
    Key? key,
    required this.user,
    this.provider,
    required this.onCameraPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;
    final isTablet = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 768;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        provider?.status == ProfileStatus.uploading
            ? _buildUploadingAvatar(context)
            : _buildAvatar(context),
        if (provider?.status != ProfileStatus.uploading)
          Positioned(
            bottom: isWeb ? 5 : 0,
            right: isWeb ? 5 : 0,
            child: _buildCameraButton(context),
          ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;
    final isTablet = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 768;
    final avatarRadius = isWeb ? 85.0 : isTablet ? 65.0 : 50.0;
    final fontSize = isWeb ? 48.0 : isTablet ? 38.0 : 32.0;
    final iconSize = isWeb ? 75.0 : isTablet ? 65.0 : 50.0;
    
    if (user.profilepicture.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isWeb ? 4 : isTablet ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: avatarRadius,
          backgroundImage: NetworkImage(user.profilepicture),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback to initial avatar on error
          },
          backgroundColor: Colors.grey.shade300,
        ),
      );
    } else {
      // Generate a gradient based on the user's name for a unique avatar
      final nameHash = user.name.isNotEmpty ? user.name.hashCode : 0;
      final hue1 = (nameHash % 360).abs().toDouble();
      final hue2 = ((nameHash ~/ 360) % 360).abs().toDouble();
      
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isWeb ? 4 : isTablet ? 3 : 2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HSLColor.fromAHSL(1, hue1, 0.7, 0.5).toColor(),
              HSLColor.fromAHSL(1, hue2, 0.7, 0.4).toColor(),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.transparent,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: fontSize, 
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildUploadingAvatar(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildAvatar(context),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
          ),
          child: CircularProgressIndicator(
            value: provider?.uploadProgress ?? 0,
            backgroundColor: Colors.white.withOpacity(0.2),
            color: Colors.white,
            strokeWidth: isWeb ? 5.0 : 3.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;
    final isTablet = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 768;
    final buttonRadius = isWeb ? 28.0 : isTablet ? 22.0 : 18.0;
    final iconSize = isWeb ? 24.0 : isTablet ? 20.0 : 18.0;
    
    return Material(
      elevation: 6,
      shape: const CircleBorder(),
      shadowColor: Colors.black.withOpacity(0.4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withRed(
                (Theme.of(context).primaryColor.red - 40).clamp(0, 255)
              ),
            ],
          ),
        ),
        child: CircleAvatar(
          radius: buttonRadius,
          backgroundColor: Colors.transparent,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: iconSize,
            color: Colors.white,
            icon: const Icon(Icons.camera_alt),
            onPressed: onCameraPressed,
            tooltip: 'Change profile picture',
          ),
        ),
      ),
    );
  }
}