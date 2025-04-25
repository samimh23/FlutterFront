import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class BarChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color barColor;

  const BarChartWidget({
    Key? key,
    required this.data,
    this.barColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> labels = List<String>.from(data['labels'] ?? []);
    final List<dynamic> rawValues = data['values'] ?? [];
    // Fix the conversion from dynamic to double
    final List<double> values = rawValues.map((v) => double.parse(v.toString())).toList();

    if (labels.isEmpty || values.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Get screen width to determine responsive behaviors
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Adjust bar width based on screen size and number of bars
    double barWidth = isSmallScreen ? max(12, 100 / max(labels.length, 1)) : 22;
    if (barWidth > 30) barWidth = 30; // Cap maximum width

    // Determine if we should rotate labels based on screen size and label count
    final bool shouldRotateLabels = isSmallScreen || labels.length > 5;

    // Determine character limit for labels based on screen size
    final int labelCharLimit = isSmallScreen ? 6 : (screenWidth < 900 ? 8 : 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            data['title'] ?? 'Chart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: values.isNotEmpty ? values.reduce(max) * 1.2 : 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${labels[groupIndex]}\n\$${values[groupIndex].toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  // Updated bottom titles with responsive font size and rotation
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          String label = labels[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: shouldRotateLabels
                                ? Transform.rotate(
                              angle: 45 * 3.1415926535 / 180,
                              child: Text(
                                label.length > labelCharLimit ? '${label.substring(0, labelCharLimit - 2)}...' : label,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
                            )
                                : Text(
                              label.length > labelCharLimit ? '${label.substring(0, labelCharLimit - 2)}...' : label,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: shouldRotateLabels ? 42 : 30,
                    ),
                  ),
                  // Updated left titles with responsive font size
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        // Show fewer labels on small screens
                        final double interval = isSmallScreen ? meta.max / 3 : meta.max / 5;
                        if (value == 0) return const Text('0');
                        if (values.isEmpty) return const Text('');

                        // Only show some values to avoid crowding
                        if (value == meta.max || value == meta.min ||
                            (value % interval < interval / 10)) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '\$${value.toInt()}',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: isSmallScreen ? 30 : 40,
                    ),
                  ),
                  // Disable right and top titles
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    left: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: values.isNotEmpty
                      ? values.reduce(max) / (isSmallScreen ? 3 : 5)
                      : 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: values.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final double value = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: barColor,
                        width: barWidth,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}