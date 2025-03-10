import 'package:flutter/material.dart';
import 'package:hanouty/app_colors.dart';

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
              gradient: const LinearGradient(
                colors: [AppColors.grey, AppColors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
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
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Your favorite minimarket',
                          style: TextStyle(
                            color: Colors.black,
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
                  child: CircleAvatar(
                    radius: 40 + (expansionFactor * 20),
                    backgroundImage: const NetworkImage(
                      'https://thumbs.dreamstime.com/b/profil-d-un-visage-triste-d-homme-d%C3%A9courag%C3%A9-sur-le-noir-48067290.jpg',
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
                            color: Colors.white,
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
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              ),
                              child: const Text('Wallet', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              ),
                              child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Follower Stats (Posts, Followers, Following)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: const [
                                  Text('23', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Product Bought', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                              Column(
                                children: const [
                                  Text('1.2K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Money Spent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                              Column(
                                children: const [
                                  Text('567', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Shop Visited', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                ],

                              ),
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
}
