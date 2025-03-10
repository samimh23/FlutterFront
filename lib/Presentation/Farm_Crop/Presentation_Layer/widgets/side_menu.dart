import 'package:flutter/material.dart';
import 'package:hanouty/Core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'theme_toggle_button.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use watch to ensure widget rebuilds when theme changes
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Text(
            'Farm Manager',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.agriculture),
          label: Text('Farm Crops'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.sell),
          label: Text('Sale'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),

        const SizedBox(height: 16),  // ✅ Fix: Use SizedBox instead of Spacer


        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(),
        ),
       
        // Using SizedBox with a fixed height instead of Spacer

        const NavigationDrawerDestination(
          icon: Icon(Icons.logout),
          label: Text('Logout'),
        ),
        
        // Theme Toggle Switch
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const ThemeToggleSwitch(),
            ],
          ),
        ),
      ],
    );
  }
}