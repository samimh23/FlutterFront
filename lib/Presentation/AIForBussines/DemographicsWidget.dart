import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // Keep if Pie chart uses it directly
import 'PieChartWidget.dart';
// import 'BarChartWidget.dart'; // No longer needed if Age Groups (BarChart) is removed

class DemographicsWidget extends StatelessWidget {
  final Map<String, dynamic> demographicsData;
  final Map<String, dynamic>? genderChart; // For Pie Chart
  // final Map<String, dynamic>? ageGroupsChart; // Removed ageGroupsChart

  const DemographicsWidget({
    Key? key,
    required this.demographicsData,
    this.genderChart,
    // this.ageGroupsChart, // Removed ageGroupsChart
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final Map<String, dynamic> ageStats = demographicsData['age_stats'] ?? {};
    final Map<String, dynamic> genderSales = demographicsData['gender_sales'] ?? {};

    // Determine if gender chart is available to avoid empty Expanded space
    final bool hasCharts = genderChart != null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isSmallScreen
              ? _buildMobileStatsView(context, ageStats, genderSales)
              : _buildDesktopStatsView(context, ageStats, genderSales),

          if (hasCharts) const SizedBox(height: 16),

          // Charts section - now only for Gender Distribution Pie Chart
          if (hasCharts)
            Expanded(
              child: _buildGenderDistributionSection(context), // Directly build gender chart
            ),
        ],
      ),
    );
  }

  // _buildMobileChartsLayout and _buildDesktopChartsLayout are no longer needed
  // as we only have one potential chart in this section now.

  // Removed _buildAgeGroupsSection method

  Map<String, dynamic> _dataWithoutTitle(Map<String, dynamic> originalData) {
    final newData = Map<String, dynamic>.from(originalData);
    newData.remove('title');
    return newData;
  }

  Widget _buildGenderDistributionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender Distribution',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: genderChart != null
              ? PieChartWidget(
            data: _dataWithoutTitle(genderChart!),
          )
              : const Center(child: Text('No gender data')),
        ),
      ],
    );
  }

  Widget _buildDesktopStatsView(
      BuildContext context,
      Map<String, dynamic> ageStats,
      Map<String, dynamic> genderSales,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(context, 'Average Age', _formatValue(ageStats['average'])),
                  _buildStatRow(context, 'Minimum Age', _formatValue(ageStats['min'])),
                  _buildStatRow(context, 'Maximum Age', _formatValue(ageStats['max'])),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales by Gender',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...genderSales.entries.map((entry) {
                    return _buildStatRow(
                        context,
                        _capitalize(entry.key),
                        '\$${_formatCurrency(entry.value)}'
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStatsView(
      BuildContext context,
      Map<String, dynamic> ageStats,
      Map<String, dynamic> genderSales,
      ) {
    return Column(
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildStatRow(context, 'Average Age', _formatValue(ageStats['average'])),
                _buildStatRow(context, 'Minimum Age', _formatValue(ageStats['min'])),
                _buildStatRow(context, 'Maximum Age', _formatValue(ageStats['max'])),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sales by Gender',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...genderSales.entries.map((entry) {
                  return _buildStatRow(
                      context,
                      _capitalize(entry.key),
                      '\$${_formatCurrency(entry.value)}'
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) {
      if (value.truncateToDouble() == value) {
        return value.toInt().toString();
      }
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0.00';
    final num numValue = num.tryParse(value.toString()) ?? 0;
    return numValue.toStringAsFixed(2);
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}