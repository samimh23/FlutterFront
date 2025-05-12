import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';

import '../../../../Core/theme/AppColors.dart';

class AnimatedHeader extends StatefulWidget {
  const AnimatedHeader({super.key});

  @override
  AnimatedHeaderState createState() => AnimatedHeaderState();
}

class AnimatedHeaderState extends State<AnimatedHeader>
    with SingleTickerProviderStateMixin {
  double _headerHeight = 108.0;
  static const double _minHeight = 108.0;
  static const double _maxHeight = 900.0;
  bool isExpanded = false;

  void _snapToState() {
    final double snapThreshold = (_maxHeight - _minHeight) / 2;
    setState(() {
      if (_headerHeight > _minHeight + snapThreshold) {
        _headerHeight = _maxHeight;
        isExpanded = true;
      } else {
        _headerHeight = _minHeight;
        isExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _headerHeight += details.delta.dy;
          _headerHeight = _headerHeight.clamp(_minHeight, _maxHeight);
        });
      },
      onVerticalDragEnd: (_) => _snapToState(),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: _minHeight, end: _headerHeight),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, height, child) {
          final expansionFactor = (height - _minHeight) / (_maxHeight - _minHeight);

          return Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              // Update to client gradient using ClientColors
              gradient: LinearGradient(
                colors: [ClientColors.primary, ClientColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: ClientColors.primary.withOpacity(0.3), // Update shadow color
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Collapsed title & subtitle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: 1 - expansionFactor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'El Hanout',
                          style: TextStyle(
                            color: ClientColors.onPrimary, // Update text color
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Your favorite minimarket',
                          style: TextStyle(
                            color: ClientColors.onPrimary, // Update text color
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Image (Position remains as before)
                Align(
                  alignment: Alignment.lerp(
                    Alignment.centerRight,
                    Alignment.topCenter,
                    expansionFactor,
                  )!,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ClientColors.secondary, // Add border in client secondary color
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ClientColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40 + (expansionFactor * 20),
                      backgroundImage: const NetworkImage(
                        'https://thumbs.dreamstime.com/b/profil-d-un-visage-triste-d-homme-d%C3%A9courag%C3%A9-sur-le-noir-48067290.jpg',
                      ),
                    ),
                  ),
                ),

                // Expanded user info
                Positioned(
                  top: 120 + (expansionFactor * 50),
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: expansionFactor,
                    child: Column(
                      children: [
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ClientColors.onPrimary, // Update text color
                          ),
                        ),
                        const SizedBox(height: 5),

                        const SizedBox(height: 10),

                        // Follow & Message Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ClientColors.secondary, // Update button color
                                foregroundColor: ClientColors.onSecondary, // Update text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              ),
                              child: const Text('Wallet'), // Text color controlled by foregroundColor
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: ClientColors.onPrimary), // Update border color
                                foregroundColor: ClientColors.onPrimary, // Update text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              ),
                              child: const Text('Edit Profile'), // Text color controlled by foregroundColor
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Statistics Section (Products, Money, Shops)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('23', 'Products Bought'),
                              _buildStatColumn('1.2K', 'Money Spent'),
                              _buildStatColumn('567', 'Shops Visited'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to create consistent stat columns
  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: ClientColors.onPrimary, // Update text color
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: ClientColors.onPrimary.withOpacity(0.7), // Update text color with opacity
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}