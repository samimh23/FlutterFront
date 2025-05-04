import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Auth/presentation/pages/profilepage.dart';
import 'package:hanouty/Presentation/order/presentation/pages/order_traking.dart';
import 'package:hanouty/Presentation/order/presentation/pages/orders_screen.dart';
import 'package:hanouty/Presentation/order/presentation/provider/order_provider.dart';
import 'package:hanouty/Presentation/product/presentation/pages/cart_screen.dart';
import 'package:hanouty/Presentation/product/presentation/pages/home_screen.dart';
import 'package:hanouty/Presentation/product/presentation/provider/cart_provider.dart';
import 'package:hanouty/Presentation/product/presentation/provider/product_provider.dart';
import 'package:hanouty/app_colors.dart';
import 'package:hanouty/responsive/responsive_layout.dart';
import 'package:hanouty/wallet_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'injection_container.dart' as di;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late AnimationController _animationController;

  // Define the navigation items
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'Home',
      icon: Icons.home_rounded,
      selectedColor: const Color(0xFF5EEAD4),
    ),
    NavigationItem(
      title: 'Cart',
      icon: Icons.shopping_cart_rounded,
      selectedColor: const Color(0xFFF97316),
      hasBadge: true,
    ),
    NavigationItem(
      title: 'Wallet',
      icon: Icons.account_balance_wallet_rounded,
      selectedColor: const Color(0xFFEAB308),
    ),
    NavigationItem(
      title: 'Orders',
      icon: Icons.receipt_rounded,
      selectedColor: const Color.fromARGB(255, 8, 227, 234),
    ),
    NavigationItem(
      title: 'Profile',
      icon: Icons.person_rounded,
      selectedColor: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const CartScreen(),
      WalletScreen(),
      const OrdersScreen(),
      const ProfilePage(),
      
    ];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<ProductProvider>()..fetchProducts(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<CartProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<OrderProvider>()),
      ],
      child: MaterialApp(
        title: 'El Hanout',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        home: Scaffold(
          body: ResponsiveLayout.isDesktop(context)
              ? _buildDesktopLayout()
              : _screens[_currentIndex],
          bottomNavigationBar: ResponsiveLayout.isDesktop(context)
              ? null
              : _buildModernBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Modern Side Navigation Bar
        _buildModernSideNavigationBar(),
        // Main Content
        Expanded(
          child: _screens[_currentIndex],
        ),
      ],
    );
  }

  Widget _buildModernSideNavigationBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo and brand
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: AppColors.teal,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'El Hanout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = index == _currentIndex;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item.selectedColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Icon with potential badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? item.selectedColor
                                  : Colors.grey.shade600,
                              size: 24,
                            ),
                            if (item.hasBadge && index == 1) // Cart index
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Consumer<CartProvider>(
                                  builder: (context, cart, child) {
                                    if (cart.newItemCount <= 0)
                                      return const SizedBox();

                                    return Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      child: Center(
                                        child: Text(
                                          cart.newItemCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? item.selectedColor
                                : Colors.grey.shade700,
                          ),
                        ),
                        // Indicator for selected item
                        if (isSelected) ...[
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.selectedColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom section with user info
         
        ],
      ),
    );
  }

  Widget _buildModernBottomNavigationBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navigationItems.length, (index) {
              final item = _navigationItems[index];
              final isSelected = index == _currentIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });

                  // Add a small animation effect
                  if (isSelected) {
                    _animationController.forward(from: 0.0);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.selectedColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with potential badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(isSelected ? 10 : 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? item.selectedColor.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? item.selectedColor
                                  : Colors.grey.shade600,
                              size: 22, // Reduced size
                            ),
                          ),
                          if (item.hasBadge && index == 1) // Cart index
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Consumer<CartProvider>(
                                builder: (context, cart, child) {
                                  if (cart.newItemCount <= 0)
                                    return const SizedBox();

                                  return Container(
                                    padding: const EdgeInsets.all(
                                        3), // Reduced padding
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16, // Reduced size
                                      minHeight: 16, // Reduced size
                                    ),
                                    child: Center(
                                      child: Text(
                                        cart.newItemCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9, // Reduced font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      // Title
                      AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.7,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 11, // Reduced font size
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? item.selectedColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Helper class for navigation items
class NavigationItem {
  final String title;
  final IconData icon;
  final Color selectedColor;
  final bool hasBadge;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.selectedColor,
    this.hasBadge = false,
  });
}
