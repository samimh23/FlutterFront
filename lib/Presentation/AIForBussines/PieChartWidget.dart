import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const PieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> labels = List<String>.from(data['labels'] ?? []);
    final List<dynamic> rawValues = data['values'] ?? [];
    // Fix the conversion from dynamic to double
    final List<double> values = rawValues.map((v) => double.parse(v.toString())).toList();

    if (labels.isEmpty || values.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Calculate total for percentages
    final double total = values.fold(0, (sum, item) => sum + item);

    // Check screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Determine if we're in a constrained container (like a card)
    final bool isConstrained = MediaQuery.of(context).size.height < 400;

    // Generate pie chart sections with responsive sizing
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.amber,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
    ];

    for (int i = 0; i < labels.length; i++) {
      final double percentage = (values[i] / total) * 100;

      // Adjust radius based on container constraints
      double radius;
      if (isConstrained) {
        radius = isSmallScreen ? 60 : 75; // Smaller radius when in confined space
      } else {
        radius = isSmallScreen ? 80 : 100;
      }

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: values[i],
          title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '', // Only show percentage if slice is big enough
          radius: radius,
          titleStyle: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          // Adjust title position to prevent overflow
          titlePositionPercentageOffset: 0.55,
        ),
      );
    }

    return LayoutBuilder(
        builder: (context, constraints) {
          // Further optimize based on available space
          final bool isVeryLimited = constraints.maxHeight < 350;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isVeryLimited)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                  child: Text(
                    data['title'] ?? 'Chart',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              Expanded(
                child: isSmallScreen || isVeryLimited
                    ? _buildMobilePieChartLayout(sections, labels, values, colors, isVeryLimited)
                    : _buildDesktopPieChartLayout(sections, labels, values, colors),
              ),
            ],
          );
        }
    );
  }

  // Desktop & tablet layout with pie chart and legend side-by-side
  Widget _buildDesktopPieChartLayout(
      List<PieChartSectionData> sections,
      List<String> labels,
      List<double> values,
      List<Color> colors) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add padding to prevent overflow
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LegendWidget(labels: labels, values: values, colors: colors),
          ),
        ),
      ],
    );
  }

  // Mobile layout with pie chart above legend
  Widget _buildMobilePieChartLayout(
      List<PieChartSectionData> sections,
      List<String> labels,
      List<double> values,
      List<Color> colors,
      bool isVeryLimited) {
    return Column(
      children: [
        // Pie chart takes 60% of space (or more if very limited)
        Expanded(
          flex: isVeryLimited ? 7 : 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add padding to prevent overflow
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: isVeryLimited ? 20 : 30, // Even smaller center space when constrained
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ),
        // Legend takes 40% of space (or less if very limited)
        Expanded(
          flex: isVeryLimited ? 3 : 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: isVeryLimited ? 4.0 : 8.0),
            child: LegendWidget(
                labels: labels,
                values: values,
                colors: colors,
                isCompact: isVeryLimited
            ),
          ),
        ),
      ],
    );
  }
}

// Extracted Legend widget for reuse and cleaner code
class LegendWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final List<Color> colors;
  final bool isCompact;

  const LegendWidget({
    Key? key,
    required this.labels,
    required this.values,
    required this.colors,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(labels.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: isCompact ? 2.0 : 4.0),
              child: Row(
                children: [
                  Container(
                    width: isCompact ? 10 : 12,
                    height: isCompact ? 10 : 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      labels[index],
                      style: TextStyle(fontSize: isCompact ? 10 : 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${values[index].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 10 : 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}