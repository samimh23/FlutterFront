// lib/Presentation/order/presentation/Page/utils/market_sorter.dart

import 'package:hanouty/Core/heritables/Markets.dart';

class MarketSorter {
  /// Sorts a list of Markets based on the specified sort option.
  ///
  /// [markets] - The list of Markets to sort
  /// [sortOption] - The sorting criteria: 'name_asc', 'name_desc', 'orders_desc', 'revenue_desc'
  /// [orderCounts] - Map of market IDs to order counts
  /// [revenues] - Map of market IDs to revenue values
  static void sortMarkets(
      List<Markets> markets,
      String sortOption,
      Map<String, int> orderCounts,
      Map<String, double> revenues,
      ) {
    switch (sortOption) {
      case 'name_asc':
        markets.sort((a, b) {
          final aName = (a as dynamic).marketName?.toString().toLowerCase() ?? '';
          final bName = (b as dynamic).marketName?.toString().toLowerCase() ?? '';
          return aName.compareTo(bName);
        });
        break;
      case 'name_desc':
        markets.sort((a, b) {
          final aName = (a as dynamic).marketName?.toString().toLowerCase() ?? '';
          final bName = (b as dynamic).marketName?.toString().toLowerCase() ?? '';
          return bName.compareTo(aName);
        });
        break;
      case 'orders_desc':
        markets.sort((a, b) {
          final aOrders = orderCounts[a.id] ?? 0;
          final bOrders = orderCounts[b.id] ?? 0;
          return bOrders.compareTo(aOrders);
        });
        break;
      case 'revenue_desc':
        markets.sort((a, b) {
          final aRevenue = revenues[a.id] ?? 0.0;
          final bRevenue = revenues[b.id] ?? 0.0;
          return bRevenue.compareTo(aRevenue);
        });
        break;
      default:
      // No sorting by default
        break;
    }
  }

  /// Gets the localized name for a sort option
  static String getSortOptionName(String sortOption) {
    switch (sortOption) {
      case 'name_asc':
        return 'Name (A-Z)';
      case 'name_desc':
        return 'Name (Z-A)';
      case 'orders_desc':
        return 'Most Orders';
      case 'revenue_desc':
        return 'Highest Revenue';
      default:
        return 'Default';
    }
  }
}