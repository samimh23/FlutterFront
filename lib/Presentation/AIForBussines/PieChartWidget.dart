import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const PieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> labels = List<String>.from(data['labels'] ?? []);
    final List<dynamic> rawValues = data['values'] ?? [];
    final List<double> values = rawValues.map((v) => double.tryParse(v.toString()) ?? 0.0).toList(); // Use tryParse

    if (labels.isEmpty || values.isEmpty || labels.length != values.length) {
      return const Center(child: Text('No data available or data mismatch'));
    }

    final double total = values.fold(0, (sum, item) => sum + item);
    if (total == 0) {
      return const Center(child: Text('Data values sum to zero'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // isConstrained is less reliable than LayoutBuilder, but we keep it for section radius logic for now
    final bool isConstrained = MediaQuery.of(context).size.height < 400;


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

    return LayoutBuilder(
        builder: (context, constraints) {
          final bool isVeryLimited = constraints.maxHeight < 200; // Made this threshold a bit more sensitive for very limited height
          // This refers to the height available to PieChartWidget specifically

          // Generate pie chart sections with responsive sizing
          // This needs to be inside LayoutBuilder if radius depends on its constraints
          final List<PieChartSectionData> sections = [];
          for (int i = 0; i < labels.length; i++) {
            final double percentage = (values[i] / total) * 100;

            // Adjust radius - this is tricky as PieChart scales. Consider this a relative guide.
            // Let's make it simpler and primarily dependent on isSmallScreen / isVeryLimited from LayoutBuilder
            double sectionRadius;
            if (isVeryLimited) {
              sectionRadius = 50;
            } else if (isSmallScreen) {
              sectionRadius = 70;
            } else {
              sectionRadius = 100;
            }
            // The actual rendered size will be constrained by the parent PieChart widget's bounds.

            sections.add(
              PieChartSectionData(
                color: colors[i % colors.length],
                value: values[i],
                // Adjust title (percentage on slice) font size more granularly
                title: percentage >= 3 ? '${percentage.toStringAsFixed(percentage > 10 ? 0 : 1)}%' : '', // Show if >=3%, less precision for larger numbers
                radius: sectionRadius,
                titleStyle: TextStyle(
                  fontSize: isVeryLimited ? 9 : (isSmallScreen ? 10 : 12), // Reduced font sizes
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                titlePositionPercentageOffset: 0.55,
              ),
            );
          }


          return Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center chart title if shown
            children: [
              // Internal title for PieChartWidget (if provided in data map)
              if (data['title'] != null && !isVeryLimited)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0), // Reduced padding
                  child: Text(
                    data['title']!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), // Smaller style
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: isSmallScreen || isVeryLimited // isVeryLimited from LayoutBuilder is more relevant here
                    ? _buildMobilePieChartLayout(sections, labels, values, colors, total, isVeryLimited, isSmallScreen)
                    : _buildDesktopPieChartLayout(sections, labels, values, colors, total),
              ),
            ],
          );
        }
    );
  }

  Widget _buildDesktopPieChartLayout(
      List<PieChartSectionData> sections,
      List<String> labels,
      List<double> values,
      List<Color> colors,
      double totalValue) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40, // Keep as is for desktop
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
            child: LegendWidget(labels: labels, values: values, colors: colors, totalValue: totalValue, isCompact: false),
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePieChartLayout(
      List<PieChartSectionData> sections,
      List<String> labels,
      List<double> values,
      List<Color> colors,
      double totalValue,
      bool isVeryLimited, // from LayoutBuilder
      bool isSmallScreen) { // from MediaQuery
    return Column(
      children: [
        Expanded(
          flex: isVeryLimited ? 7 : 6, // Give more space to pie if very limited
          child: Padding(
            padding: const EdgeInsets.all(4.0), // Reduced padding around chart itself for more drawing space
            child: PieChart(
              PieChartData(
                sections: sections,
                // Make center space a bit larger for thinner pie on mobile, can help with label fitting
                centerSpaceRadius: isVeryLimited ? 25 : (isSmallScreen ? 30 : 40),
                sectionsSpace: 1, // Reduced space between sections
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: isVeryLimited ? 3 : 4, // Less space for legend if very limited
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: isVeryLimited ? 2.0 : 4.0), // Reduced padding
            child: LegendWidget(
                labels: labels,
                values: values,
                colors: colors,
                totalValue: totalValue,
                isCompact: true // Always use compact legend for mobile layouts
            ),
          ),
        ),
      ],
    );
  }
}

class LegendWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final List<Color> colors;
  final double totalValue;
  final bool isCompact;

  const LegendWidget({
    Key? key,
    required this.labels,
    required this.values,
    required this.colors,
    required this.totalValue,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalValue == 0) {
      return const Center(child: Text("N/A")); // Shorter message
    }
    return SingleChildScrollView( // Important for scrollable legend if items overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(labels.length, (index) {
            if (index >= values.length) return const SizedBox.shrink(); // Safety check
            final double percentage = (values[index] / totalValue) * 100;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: isCompact ? 1.0 : 3.0), // Tighter vertical padding
              child: Row(
                children: [
                  Container(
                    width: isCompact ? 8 : 10, // Smaller indicator
                    height: isCompact ? 8 : 10,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4), // Reduced space
                  Expanded(
                    child: Text(
                      labels[index],
                      style: TextStyle(fontSize: isCompact ? 10 : 12), // Slightly smaller
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(percentage >=10 ? 0 : 1)}%', // Less precision for larger numbers
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 10 : 12, // Slightly smaller
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