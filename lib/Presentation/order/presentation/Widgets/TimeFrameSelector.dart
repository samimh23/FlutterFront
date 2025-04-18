// lib/Presentation/order/presentation/Page/widgets/time_frame_selector.dart

import 'package:flutter/material.dart';

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
                    ? const Color(0xFF43A047).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF43A047)
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                timeFrame,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF43A047)
                      : Colors.grey[600],
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