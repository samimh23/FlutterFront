import 'package:flutter/material.dart';
import 'package:hanouty/Presentation/Farm/Presentation_Layer/pages/FarmListScreen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_data.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../Sales/Presentation_Layer/pages/sale_dashboard.dart';
import 'farm_crop_manager.dart';
import '../widgets/side_menu.dart'; // Your existing side menu widget

class FarmMainScreen extends StatefulWidget {
  const FarmMainScreen({Key? key}) : super(key: key);

  @override
  State<FarmMainScreen> createState() => _FarmMainScreen();
}

class _FarmMainScreen extends State<FarmMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    FarmListScreen(), // Placeholder for Dashboard
    const FarmCropManager(), // FarmCropManager screen
    const SaleDashboard(), // SaleDashboard screen
    const Center(child: Text('Profile')), // Placeholder for Profile
  ];

  void _handleLogout() {
    // Implement logout logic here
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _handleNavigation(int index) {
    if (index == 4) { // Logout index (adjusted to match the number of items)
      _handleLogout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Row(
      children: [
        SideMenu(
          selectedIndex: _selectedIndex,
          onItemSelected: _handleNavigation,
        ),
        Expanded(
          child: _screens[_selectedIndex],
        ),
      ],
    ),
  );
}
}