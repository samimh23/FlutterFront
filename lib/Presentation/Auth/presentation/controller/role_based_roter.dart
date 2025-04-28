import 'package:flutter/material.dart';
import 'package:hanouty/Core/Enums/role_enum.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Pages/dashboard_page.dart';

import '../../../Farm/Presentation_Layer/pages/mobile/FarmMobileNavigation.dart';


  class RoleBasedRouter {
    // Navigate based on user role
    static void navigateBasedOnRole(BuildContext context, Role role) {
      switch (role) {
        case Role.Client:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case Role.Farmer:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmMobileNavigation())
          );
          break;
        case Role.Merchant:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage())
          );
          break;
        default:
        // Default to home page for other roles
          Navigator.pushReplacementNamed(context, '/home');
          break;
      }
    }
  }