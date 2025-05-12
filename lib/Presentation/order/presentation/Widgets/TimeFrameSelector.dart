import 'package:flutter/material.dart';
import 'package:hanouty/Core/theme/AppColors.dart'; // Add this import

class TimeFrameSelector extends StatelessWidget {
  final List<String> timeFrames;
  final String selectedTimeFrame;
  final Function(String) onTimeFrameSelected;

  const TimeFrameSelector({
    Key? key,
    required this.timeFrames,
    required this.selectedTimeFrame,
    required this.onTimeFrameSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: timeFrames.map((timeFrame) {
          final isSelected = selectedTimeFrame == timeFrame;
          return GestureDetector(
            onTap: () {
              onTimeFrameSelected(timeFrame);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? MarketOwnerColors.primary.withOpacity(0.1) // Use primary blue with opacity
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? MarketOwnerColors.primary // Use primary blue for selected item
                      : MarketOwnerColors.secondary.withOpacity(0.3), // Use secondary blue with opacity
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                timeFrame,
                style: TextStyle(
                  color: isSelected
                      ? MarketOwnerColors.primary // Use primary blue for selected text
                      : MarketOwnerColors.textLight, // Use lighter text color for unselected
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}