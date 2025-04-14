import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/data/models/user.dart';
import 'package:hanouty/Presentation/Auth/presentation/controller/profilep%5Erovider.dart';
import 'package:hanouty/Presentation/Auth/presentation/widgets/profile/profile_avatar.dart';

class ProfileAppBar extends StatelessWidget {
  final User user;
  final ProfileProvider provider;
  final VoidCallback onCameraPressed;

  const ProfileAppBar({
    Key? key,
    required this.user,
    required this.provider,
    required this.onCameraPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 768;
    final isTablet = screenWidth > 600 && screenWidth <= 768;
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: isWeb ? 320.0 : isTablet ? 260.0 : 220.0,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: theme.primaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // Navigate to settings
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withBlue((theme.primaryColor.blue + 30).clamp(0, 255)),
                    theme.primaryColor,
                    theme.primaryColor.withRed((theme.primaryColor.red - 30).clamp(0, 255)),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            // Decorative pattern overlay
            Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/pattern.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
            
            // Decorative elements - subtle curved shapes
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: isWeb ? 300 : 200,
                height: isWeb ? 300 : 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Positioned(
              bottom: -100,
              left: -50,
              child: Container(
                width: isWeb ? 250 : 180,
                height: isWeb ? 250 : 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Web-specific decorative elements
            if (isWeb)
              Positioned(
                top: 40,
                left: screenWidth * 0.2,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
            if (isWeb)
              Positioned(
                bottom: 30,
                right: screenWidth * 0.25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            
            // User info content with responsive layout
            SafeArea(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isWeb ? 40 : isTablet ? 30 : 20),
                        
                        // Profile avatar with hero animation
                        Hero(
                          tag: 'profile-avatar-${user.id}',
                          child: ProfileAvatar(
                            user: user,
                            provider: provider,
                            onCameraPressed: onCameraPressed,
                          ),
                        ),
                        
                        SizedBox(height: isWeb ? 28 : isTablet ? 22 : 16),
                        
                        // User name with enhanced styling
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: isWeb ? 32 : isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}