import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BarChartWidget.dart'; // Assuming these files exist
import 'DashboardViewModel.dart'; // Assuming these files exist
import 'MarketSelector.dart'; // Assuming these files exist
import 'PieChartWidget.dart'; // Assuming these files exist
import 'StatsCard.dart'; // Assuming these files exist
import 'DemographicsWidget.dart'; // Assuming these files exist

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Market list is loaded in the ViewModel constructor now
    // No need to explicitly call loadAllData here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<DashboardViewModel>(
          builder: (context, viewModel, _) {
            String marketInfo = '';
            if (viewModel.selectedMarketId != null) {
              final marketName = viewModel.getMarketName(viewModel.selectedMarketId);
              final marketLocation = viewModel.getMarketLocation(viewModel.selectedMarketId);
              marketInfo = ' - $marketName ($marketLocation)';
            }
            return Text('My Markets$marketInfo');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
              viewModel.loadAllData();
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isDesktop = screenWidth > 1200;
              final isTablet = screenWidth > 600 && screenWidth <= 1200;

              return RefreshIndicator(
                onRefresh: () => viewModel.loadAllData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24.0 : (isTablet ? 20.0 : 12.0),
                        vertical: 16.0
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Add Market Selector at the top
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 1200 : (isTablet ? 900 : double.infinity),
                            ),
                            child: MarketSelector(
                              markets: viewModel.availableMarkets,
                              userMarkets: viewModel.userMarkets,
                              selectedMarketId: viewModel.selectedMarketId,
                              onMarketSelected: (marketId) {
                                viewModel.selectMarket(marketId);
                              },
                              isLoading: viewModel.isLoadingMarkets,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Show loading indicator
                        if (viewModel.isLoading)
                          const Center(child: CircularProgressIndicator())
                        // Show error if present
                        else if (viewModel.error != null)
                          _buildErrorView(viewModel)
                        // Otherwise show dashboard content
                        else
                          Column(
                            children: [
                              // Stats Card - constrained width for desktop to avoid being too big
                              if (viewModel.stats != null)
                                Center(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: isDesktop ? 1200 : (isTablet ? 900 : double.infinity),
                                    ),
                                    child: StatsCard(stats: viewModel.stats!),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Choose layout based on screen size
                              if (isDesktop)
                                _buildDesktopLayout(viewModel)
                              else if (isTablet)
                                _buildTabletLayout(viewModel)
                              else
                                _buildMobileLayout(viewModel),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorView(DashboardViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.loadAllData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Desktop layout: 2x2 grid with demographics section
  Widget _buildDesktopLayout(DashboardViewModel viewModel) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // First Row - Category and Location Sales
            _buildChartRow(
              viewModel.categorySalesChart,
              viewModel.locationSalesChart,
              height: 380,
              title1: 'Category Sales',
              title2: 'Location Sales',
              color1: Colors.blue,
              color2: Colors.green,
            ),

            const SizedBox(height: 20),

            // Second Row - Gender Distribution and Seasonal Sales
            _buildChartRow(
              viewModel.genderDistributionChart,
              viewModel.seasonalSalesChart,
              height: 380,
              title1: 'Gender Distribution',
              title2: 'Seasonal Sales',
              color1: null, // Pie chart doesn't need color
              color2: Colors.orange,
              isPieChart1: true,
            ),

            const SizedBox(height: 20),

            // Demographics Section
            if (viewModel.demographics != null)
              _buildChartCard(
                title: 'Customer Demographics',
                height: 500, // Keep original height for desktop for more detail
                child: DemographicsWidget(
                  demographicsData: viewModel.demographics!,
                  genderChart: viewModel.genderDistributionChart,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(DashboardViewModel viewModel) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            // First Row - Category and Location Sales
            _buildChartRow(
              viewModel.categorySalesChart,
              viewModel.locationSalesChart,
              height: 300,
              title1: 'Category Sales',
              title2: 'Location Sales',
              color1: Colors.blue,
              color2: Colors.green,
              spacing: 16,
            ),

            // Gender Distribution Pie Chart
            if (viewModel.genderDistributionChart != null)
              _buildChartCard(
                title: 'Gender Distribution',
                height: 300,
                child: PieChartWidget(
                  data: viewModel.genderDistributionChart!,
                ),
              ),

            // Seasonal Sales Chart
            if (viewModel.seasonalSalesChart != null)
              _buildChartCard(
                title: 'Seasonal Sales',
                height: 300,
                child: BarChartWidget(
                  data: viewModel.seasonalSalesChart!,
                  barColor: Colors.orange,
                ),
              ),

            // Demographics Section
            if (viewModel.demographics != null)
              _buildChartCard(
                title: 'Customer Demographics',
                height: 450, // Keep original height for tablet
                child: DemographicsWidget(
                  demographicsData: viewModel.demographics!,
                  genderChart: viewModel.genderDistributionChart,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Updated Mobile Layout
  Widget _buildMobileLayout(DashboardViewModel viewModel) {
    // Adjusted heights for better mobile experience
    const double mobileChartHeight = 230;
    const double mobileDemographicsHeight = 480; // Increased from 400

    return Column(
      children: [
        // Category Sales Chart
        if (viewModel.categorySalesChart != null)
          _buildChartCard(
            title: 'Category Sales',
            height: mobileChartHeight,
            child: BarChartWidget(
              data: viewModel.categorySalesChart!,
              barColor: Colors.blue,
            ),
          ),

        // Location Sales Chart
        if (viewModel.locationSalesChart != null)
          _buildChartCard(
            title: 'Location Sales',
            height: mobileChartHeight,
            child: BarChartWidget(
              data: viewModel.locationSalesChart!,
              barColor: Colors.green,
            ),
          ),

        // Gender Distribution Pie Chart
        if (viewModel.genderDistributionChart != null)
          _buildChartCard(
            title: 'Gender Distribution',
            height: mobileChartHeight,
            child: PieChartWidget(
              data: viewModel.genderDistributionChart!,
            ),
          ),

        // Seasonal Sales Chart
        if (viewModel.seasonalSalesChart != null)
          _buildChartCard(
            title: 'Seasonal Sales',
            height: mobileChartHeight,
            child: BarChartWidget(
              data: viewModel.seasonalSalesChart!,
              barColor: Colors.orange,
            ),
          ),

        // Demographics Section
        if (viewModel.demographics != null)
          _buildChartCard(
            title: 'Customer Demographics',
            height: mobileDemographicsHeight, // Use new, increased height
            child: DemographicsWidget(
              demographicsData: viewModel.demographics!,

            ),
          ),
      ],
    );
  }

  // Helper method to build a row with two charts
  Widget _buildChartRow(
      Map<String, dynamic>? data1,
      Map<String, dynamic>? data2, {
        required double height,
        required String title1,
        required String title2,
        Color? color1,
        Color? color2,
        bool isPieChart1 = false,
        bool isPieChart2 = false,
        double spacing = 20,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data1 != null)
          Expanded(
            child: _buildChartCard(
              title: title1,
              height: height,
              child: isPieChart1
                  ? PieChartWidget(data: data1)
                  : BarChartWidget(
                data: data1,
                barColor: color1 ?? Colors.blue,
              ),
            ),
          ),
        if (data1 != null && data2 != null)
          SizedBox(width: spacing),
        if (data2 != null)
          Expanded(
            child: _buildChartCard(
              title: title2,
              height: height,
              child: isPieChart2
                  ? PieChartWidget(data: data2)
                  : BarChartWidget(
                data: data2,
                barColor: color2 ?? Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  // Fixed Card widget for all charts
  Widget _buildChartCard({required String title, required Widget child, required double height}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: child,
                )
            ),
          ],
        ),
      ),
    );
  }
}