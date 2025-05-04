import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Farm_Crop/Presentation_Layer/pages/FarmCropListScreen.dart';
import '../../viewmodels/farmviewmodel.dart';
import 'FarmMobileDetailScreen.dart';
import 'FarmMobileListScreen.dart';
import 'FarmMobileMarketSceen.dart';
import 'MobileDetectionDesease.dart';
import 'MobileProductDesease.dart';

class FarmMobileNavigation extends StatefulWidget {
  const FarmMobileNavigation({Key? key}) : super(key: key);

  @override
  State<FarmMobileNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<FarmMobileNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FarmMarketplaceScreen(),
    const FarmListScreen(),
    const MobileProductDetectDisease(),
    // const DiseaseDetectionMobileScreen(),
    const FarmCropsListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Refresh farm data when switching tabs
          final viewModel = Provider.of<FarmMarketViewModel>(context, listen: false);
          viewModel.fetchAllFarmMarkets();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Manage Farms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Product IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nature),
            label: 'Crop',
          ),
        ],
      ),
    );
  }
}