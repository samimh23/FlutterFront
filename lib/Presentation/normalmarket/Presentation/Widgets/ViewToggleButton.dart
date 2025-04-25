// lib/Presentation/order/presentation/Page/widgets/view_toggle_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewToggleButton extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final bool isDarkMode;

  const ViewToggleButton({
    Key? key,
    required this.isSelected,
    required this.icon,
    required this.onPressed,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
    final selectedColor = isSelected ? accentColor : (isDarkMode ? Colors.grey.shade600 : Colors.grey);
    final selectedBgColor = isSelected
        ? accentColor.withOpacity(0.1)
        : Colors.transparent;

    return Material(
      color: selectedBgColor,
      borderRadius: BorderRadius.circular(isMediumScreen ? 6 : 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(isMediumScreen ? 6 : 8),
        child: Padding(
          padding: EdgeInsets.all(isMediumScreen ? 6 : 8),
          child: Icon(
            icon,
            color: selectedColor,
            size: isMediumScreen ? 18 : 22,
          ),
        ),
      ),
    );
  }
}