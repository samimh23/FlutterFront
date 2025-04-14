import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'PieChartWidget.dart';
import 'BarChartWidget.dart';

class DemographicsWidget extends StatelessWidget {
  final Map<String, dynamic> demographicsData;
  final Map<String, dynamic>? genderChart;
  final Map<String, dynamic>? ageGroupsChart;

  const DemographicsWidget({
    Key? key,
    required this.demographicsData,
    this.genderChart,
    this.ageGroupsChart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final Map<String, dynamic> ageStats = demographicsData['age_stats'] ?? {};
    final Map<String, dynamic> genderSales = demographicsData['gender_sales'] ?? {};

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics section
          isSmallScreen
              ? _buildMobileStatsView(context, ageStats, genderSales)
              : _buildDesktopStatsView(context, ageStats, genderSales),

          const SizedBox(height: 20),

          // Charts section - make it expandable
          Expanded(
            child: isSmallScreen
                ? Column(
              children: [
          


                if (ageGroupsChart != null)
                  Expanded(
                    flex: 1,
                    child: _buildAgeGroupsSection(context),
                  ),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                if (ageGroupsChart != null)
                  Expanded(
                    flex: 1,
                    child: _buildAgeGroupsSection(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAgeGroupsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Groups',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ageGroupsChart != null
              ? BarChartWidget(
            data: ageGroupsChart!,
            barColor: Colors.purple,
          )
              : const Center(child: Text('No age group data available')),
        ),
      ],
    );
  }

  Widget _buildDesktopStatsView(BuildContext context,
      Map<String, dynamic> ageStats, Map<String, dynamic> genderSales) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow('Average Age', _formatValue(ageStats['average'])),
                  _buildStatRow('Minimum Age', _formatValue(ageStats['min'])),
                  _buildStatRow('Maximum Age', _formatValue(ageStats['max'])),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales by Gender',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...genderSales.entries.map((entry) {
                    return _buildStatRow(
                        entry.key,
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

  Widget _buildMobileStatsView(BuildContext context,
      Map<String, dynamic> ageStats, Map<String, dynamic> genderSales) {
    return Column(
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildStatRow('Average Age', _formatValue(ageStats['average'])),
                _buildStatRow('Minimum Age', _formatValue(ageStats['min'])),
                _buildStatRow('Maximum Age', _formatValue(ageStats['max'])),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sales by Gender',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...genderSales.entries.map((entry) {
                  return _buildStatRow(
                      entry.key,
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

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) {
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    }
    return value.toString();
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0.00';
    final num numValue = num.tryParse(value.toString()) ?? 0;
    return numValue.toStringAsFixed(2);
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}