import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'apiservice.dart';
import 'market.dart';
import 'MarketService.dart'; // Make sure this import path matches your project structure

class DashboardViewModel with ChangeNotifier {
  final ApiService _apiService;
  final MarketService _marketService = MarketService(); // Initialize MarketService

  Map<String, dynamic>? stats;
  Map<String, dynamic>? categories;
  Map<String, dynamic>? locations;
  Map<String, dynamic>? timeAnalysis;
  Map<String, dynamic>? demographics;
  Map<String, dynamic>? categorySalesChart;
  Map<String, dynamic>? locationSalesChart;
  Map<String, dynamic>? genderDistributionChart;
  Map<String, dynamic>? seasonalSalesChart;
  Map<String, dynamic>? ageGroupsChart;

  bool isLoading = false;
  String? error;

  // Market selection properties
  List<Market> userMarkets = []; // Store full market objects
  List<String> availableMarkets = []; // This will now store only the user's market IDs
  String? selectedMarketId;
  bool isLoadingMarkets = false;

  // Current user
  final String currentUser = 'samimh23';

  DashboardViewModel(this._apiService) {
    // Load user's markets when ViewModel is initialized
    loadUserMarkets();
  }

  // Method to load user's markets
  // Update loadUserMarkets method in DashboardViewModel
  Future<void> loadUserMarkets() async {
    try {
      isLoadingMarkets = true;
      error = null;
      notifyListeners();

      log('DashboardViewModel: Loading user markets...');

      // Get markets owned by the current user
      userMarkets = await _marketService.getMyMarkets();

      log('DashboardViewModel: Loaded ${userMarkets.length} markets');

      // Always ensure we have at least demo markets
      if (userMarkets.isEmpty) {
        log('No markets returned, using demo markets');
        userMarkets = [
          Market(
              id: 'demo1',
              name: 'Demo Market 1',
              marketLocation: 'Test Location',
              owner: currentUser
          ),
          Market(
              id: 'demo2',
              name: 'Demo Market 2',
              marketLocation: 'Another Location',
              owner: currentUser
          ),
        ];
      }

      // Print each market for debugging
      for (var market in userMarkets) {
        log('Market loaded: ${market.name} (${market.marketLocation}) - ID: ${market.id}');
      }
      // Extract market IDs for compatibility with existing code
      availableMarkets = userMarkets.map((market) => market.id).toList();
      log('Available market IDs: $availableMarkets');

      isLoadingMarkets = false;
      notifyListeners();

      // Load data after markets are loaded
      loadAllData();
    } catch (e) {
      log('Error loading markets: $e', error: e);
      isLoadingMarkets = false;
      error = 'Failed to load your markets: $e';

      // Add some demo markets even on error
      userMarkets = [
        Market(
            id: 'error1',
            name: 'Demo Market (Error Fallback)',
            marketLocation: 'Error Occurred',
            owner: currentUser
        ),
      ];
      availableMarkets = userMarkets.map((market) => market.id).toList();

      notifyListeners();
    }
  }

  // Get market name by ID
  String getMarketName(String? id) {
    if (id == null) return 'All My Markets';

    final market = userMarkets.firstWhere(
          (m) => m.id == id,
      orElse: () => Market(
          id: id,
          name: 'Market $id',
          marketLocation: 'Unknown Location',
          owner: currentUser
      ),
    );

    return market.name;
  }

  // Get market location by ID
  String getMarketLocation(String? id) {
    if (id == null) return '';

    final market = userMarkets.firstWhere(
          (m) => m.id == id,
      orElse: () => Market(
          id: id,
          name: 'Market $id',
          marketLocation: 'Unknown Location',
          owner: currentUser
      ),
    );

    return market.marketLocation;
  }

  // Method to select a market
  void selectMarket(String? marketId) {
    if (selectedMarketId != marketId) {
      selectedMarketId = marketId;
      notifyListeners();

      // Reload data with the new selected market
      loadAllData();
    }
  }

  // Rest of your existing methods remain unchanged...
  Future<void> loadAllData() async {
    try {
      setLoading(true);

      await Future.wait([
        loadStats(),
        loadCategorySalesChart(),
        loadLocationSalesChart(),
        loadGenderDistributionChart(),
        loadSeasonalSalesChart(),
        loadDemographics(),
      ]);

      setLoading(false);
    } catch (e) {
      setError('Failed to load dashboard data: $e');
    }
  }

  Future<void> loadDemographics() async {
    try {
      demographics = null;
      ageGroupsChart = null;
      demographics = await _apiService.fetchDemographics(marketId: selectedMarketId);

      // Process age groups data for charts if available
      final ageStats = demographics?['age_stats'] ?? {};
      if (ageStats.containsKey('groups')) {
        final Map<String, dynamic> groups = Map<String, dynamic>.from(ageStats['groups']);

        // Sort age groups in logical order
        final List<String> orderedLabels = [];
        final List<dynamic> orderedValues = [];

        // Define the expected order of age groups
        final List<String> expectedOrder = ['<25', '25-34', '35-44', '45-54', '55+'];

        // Add groups in expected order if they exist
        for (String ageGroup in expectedOrder) {
          if (groups.containsKey(ageGroup)) {
            orderedLabels.add(ageGroup);
            orderedValues.add(groups[ageGroup]);
          }
        }

        // Add to loadDemographics after processing age groups
        if (demographics?.containsKey('gender_distribution') == true) {
          final genderDist = demographics!['gender_distribution'];
          final labels = genderDist.keys.toList();
          final values = genderDist.values.map((v) => v.toDouble()).toList();

          genderDistributionChart = {
            'title': 'Gender Distribution',
            'labels': labels,
            'values': values,
          };
        }

        // Add any remaining groups that weren't in our expected list
        for (var entry in groups.entries) {
          if (!orderedLabels.contains(entry.key)) {
            orderedLabels.add(entry.key);
            orderedValues.add(entry.value);
          }
        }

        ageGroupsChart = {
          'title': 'Age Group Distribution',
          'labels': orderedLabels,
          'values': orderedValues.map((v) => double.parse(v.toString())).toList(),
        };
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to load demographics data: $e');
    }
  }

  Future<void> loadStats() async {
    try {
      stats = await _apiService.fetchStats(marketId: selectedMarketId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load stats: $e');
    }
  }

  Future<void> loadCategorySalesChart() async {
    try {
      categorySalesChart = await _apiService.fetchCategorySalesChart(marketId: selectedMarketId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load category sales chart: $e');
    }
  }

  Future<void> loadLocationSalesChart() async {
    try {
      locationSalesChart = await _apiService.fetchLocationSalesChart(marketId: selectedMarketId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load location sales chart: $e');
    }
  }

  Future<void> loadGenderDistributionChart() async {
    try {
      genderDistributionChart = await _apiService.fetchGenderDistributionChart(marketId: selectedMarketId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load gender distribution chart: $e');
    }
  }

  Future<void> loadSeasonalSalesChart() async {
    try {
      seasonalSalesChart = await _apiService.fetchSeasonalSalesChart(marketId: selectedMarketId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load seasonal sales chart: $e');
    }
  }

  void setLoading(bool loading) {
    isLoading = loading;
    if (loading) {
      error = null;
    }
    notifyListeners();
  }

  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  // Helper method to get the current market name for display
  String getCurrentMarketName() {
    if (selectedMarketId == null) {
      return 'My Markets';  // Changed from 'All Markets' to 'My Markets'
    }
    return getMarketName(selectedMarketId);
  }
}